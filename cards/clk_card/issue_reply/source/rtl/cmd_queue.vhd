-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: cmd_queue.vhd,v 1.29 2004/07/30 00:19:29 bench2 Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This file implements the cmd_queue block in the issue/reply hardware
-- on the clock card.
--
-- Revision history:
-- $Log: cmd_queue.vhd,v $
-- Revision 1.29  2004/07/30 00:19:29  bench2
-- Bryce: in progress
--
-- Revision 1.28  2004/07/29 00:40:19  bench2
-- Bryce: in progress
--
-- Revision 1.27  2004/07/27 22:42:02  bench2
-- Bryce: in progress
--
-- Revision 1.26  2004/07/27 01:36:04  bench2
-- Bryce: in progress
--
-- Revision 1.25  2004/07/26 19:31:13  bench2
-- Bryce: in progress
--
-- Revision 1.24  2004/07/22 23:43:31  bench2
-- Bryce: in progress
--
-- Revision 1.23  2004/07/22 20:39:08  bench2
-- Bryce: in progress
--
-- Revision 1.1  2004/05/11 02:17:31  bburger
-- new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.frame_timing_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;
use work.cmd_queue_ram40_pack.all;
use work.async_pack.all;

entity cmd_queue is
   port(
      -- reply_queue interface
      uop_status_i  : in std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
      uop_rdy_o     : out std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
      uop_ack_i     : in std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
      uop_discard_o : out std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.
      uop_timedout_o: out std_logic; -- Tells that reply_queue that it should generated a timed-out reply based on the the par_id, card_addr, etc of the u-op being retired.
      uop_o         : out std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

      -- cmd_translator interface
      card_addr_i   : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- The card address of the m-op
      par_id_i      : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- The parameter id of the m-op
      data_size_i   : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- The number of 32-bit words of data in the m-op
      data_i        : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- Data belonging to a m-op
      data_clk_i    : in std_logic; -- Clocks in 32-bit wide data
      mop_i         : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- M-op sequence number
      issue_sync_i  : in std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0); -- The issuing sync-pulse sequence number
      mop_rdy_i     : in std_logic; -- Tells cmd_queue when a m-op is ready
      mop_ack_o     : out std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op and is ready to receive data
      
      -- lvds_tx interface
      tx_o          : out std_logic;  -- transmitter output pin
      clk_200mhz_i  : in std_logic;  -- PLL locked 25MHz input clock for the

      -- Clock lines
      sync_i        : in std_logic; -- The sync pulse determines when and when not to issue u-ops
      clk_i         : in std_logic; -- Advances the state machines
      rst_i         : in std_logic  -- Resets all FSMs
   );
end cmd_queue;

architecture behav of cmd_queue is

constant ADDR_ZERO          : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0) := (others => '0');
constant ADDR_FULL_SCALE    : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0) := (others => '1');
constant TIMEOUT_LEN        : std_logic_vector(TIMEOUT_SYNC_BUS_WIDTH-1 downto 0) := "00000001";  -- The number of sync pulses after which an instruction will expire
constant MAX_SYNC_COUNT     : integer := 255;
--constant MAX_BIT_COUNT      : integer := 32;

-- Command queue inputs/ouputs (this interface was generated by a Quartus II megafunction for a RAM block)
signal data_sig             : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal wraddress_sig        : std_logic_vector(7 downto 0);
signal rdaddress_a_sig      : std_logic_vector(7 downto 0);
signal rdaddress_b_sig      : std_logic_vector(7 downto 0);
signal wren_sig             : std_logic;
signal qa_sig               : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal qb_sig               : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal nfast_clk            : std_logic;
signal n_clk                : std_logic;

-- Indicates the number u-ops contained in the command queue
signal uop_counter          : std_logic_vector(UOP_BUS_WIDTH - 1 downto 0);

-- Sync-pulse counter inputs/outputs.  These are used to determine when u-ops have expired.
signal sync_count_slv       : std_logic_vector(7 downto 0);
signal sync_count_int       : integer;
signal clk_count            : integer;
signal clk_error            : std_logic_vector(31 downto 0);

-- Command queue management variables
signal uops_generated       : integer;
signal cards_addressed      : integer;
signal num_uops             : integer;
signal data_size_int        : integer;
signal size_uops            : integer;
signal num_uops_inserted    : integer; --determines when to stop inserting u-ops
signal queue_space          : integer := QUEUE_LEN;

-- Command queue address pointers.  Each one of these are managed by a different FSM.
signal retire_ptr           : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal flush_ptr            : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal send_ptr             : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal free_ptr             : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);

-- Insertion FSM:  inserts u-ops into the command queue
type insert_states is (IDLE, INSERT_HDR1, INSERT_HDR2, INSERT_DATA, DONE, RESET);
signal present_insert_state : insert_states;
signal next_insert_state    : insert_states;
signal data_count           : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
signal insert_uop_ack       : std_logic; --tells the generate FSM when the insert FSM is ready to insert the next u-op
signal num_uops_inserted_slv: std_logic_vector(UOP_BUS_WIDTH-1 downto 0);

-- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
type retire_states is (IDLE, NEXT_UOP, STATUS, RETIRE, FLUSH, EJECT, NEXT_FLUSH, FLUSH_STATUS, RESET);
signal present_retire_state : retire_states;
signal next_retire_state    : retire_states;
signal retired              : std_logic; --Out, to the u-op counter fsm
signal uop_timed_out        : std_logic;

-- Generate FSM:  translates M-ops into u-ops
type gen_uop_states is (IDLE, INSERT, 
                        --PS_CARD, CLOCK_CARD, ADDR_CARD, READOUT_CARD1, READOUT_CARD2, READOUT_CARD3, READOUT_CARD4, BIAS_CARD1, BIAS_CARD2, BIAS_CARD3, 
                        CLEANUP, RESET, DONE);
signal present_gen_state    : gen_uop_states;
signal next_gen_state       : gen_uop_states;
signal mop_rdy              : std_logic; --In from the previous block in the chain  
signal insert_uop_rdy       : std_logic; --Out, to insertion fsm, tells the insert FSM when a new u-op is available
signal new_card_addr        : std_logic_vector(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0); --out, to insertion fsm
signal new_par_id           : std_logic_vector(CQ_PAR_ID_BUS_WIDTH-1 downto 0) := x"00"; --out, to insertion fsm.  This is a hack.

-- Send FSM:  sends u-ops over the bus backplane
type send_states is (LOAD, ISSUE, HEADER_A, HEADER_B, DATA, MORE_DATA, CHECKSUM, NEXT_UOP, RESET, PREGNANT_PAUSE);
signal present_send_state   : send_states;
signal next_send_state      : send_states;
signal previous_send_state  : send_states;
signal freeze_send          : std_logic;  --In, freezes the send pointer when flushing out invalidated u-ops
signal uop_send_expired     : std_logic;
signal issue_sync           : std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);
signal timeout_sync         : std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);
signal uop_data_size        : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
signal uop_data_size_int    : integer;
signal uop_data_count       : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);

-- Wishbone signals to/from lvds_tx
signal cmd_tx_dat           : std_logic_vector(31 downto 0);
signal cmd_tx_start         : std_logic;
signal cmd_tx_done          : std_logic;

-- CRC signals:
signal crc_clr              : std_logic;
signal crc_ena              : std_logic;
signal crc_data             : std_logic;
signal crc_num_bits         : integer;
signal crc_done             : std_logic;
signal crc_valid            : std_logic;
signal crc_checksum         : std_logic_vector(CHECKSUM_BUS_WIDTH-1 downto 0);
signal crc_start            : std_logic; --Not part of the interface to the crc block; enables sh_reg and bit_ctr.
signal crc_reg              : std_logic_vector(CHECKSUM_BUS_WIDTH-1 downto 0);

-- Shift Register signals:
signal sh_reg_serial_o      : std_logic;
signal sh_reg_parallel_i    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
signal sh_reg_parallel_o    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0); --Dummy signal

-- Bit Counter signals
signal bit_ctr_count        : integer;
signal bit_ctr_ena          : std_logic; -- enables the counter which controls the enable line to the CRC block.  The counter should only be functional when there is a to calculate.

-- Constants that can be removed when the sync_counter and frame_timer are moved out of this block
constant HIGH               : std_logic := '1';
constant LOW                : std_logic := '0';
constant INT_ZERO           : integer := 0;

begin
   -- Command queue (FIFO)
   cmd_queue_ram40_inst: cmd_queue_ram40_test
      port map(
         data        => data_sig,
         wraddress   => wraddress_sig,
         rdaddress_a => rdaddress_a_sig,
         rdaddress_b => rdaddress_b_sig,
         wren        => wren_sig,
         clock       => n_clk,         
         qa          => qa_sig, -- qa_sig data are used by the send FSM         
         qb          => qb_sig -- qb_sig data are used by the retire FSM
      );

   -- The sync counter will be moved outside this block
   sync_counter: counter
      generic map(
         MAX         => MAX_SYNC_COUNT,
         STEP_SIZE   => 1, 
         WRAP_AROUND => LOW, 
         UP_COUNTER  => HIGH        
         )
      port map(
         clk_i       => sync_i,
         rst_i       => rst_i,
         ena_i       => HIGH,
         load_i      => LOW,
         count_i     => INT_ZERO,
         count_o     => sync_count_int
      );

   frame_timer: frame_timing
     port map(
         clk_i       => clk_i,
         sync_i      => sync_i,
         frame_rst_i => rst_i,
         clk_count_o => clk_count,
         clk_error_o => clk_error
     );

   -- lvds_tx is the LVDS interface to the Bus Backplane
   cmd_tx: lvds_tx
      port map(
         clk_i      => clk_i,
         comm_clk_i => clk_200mhz_i,
         rst_i      => rst_i,
         dat_i      => cmd_tx_dat,
         start_i    => cmd_tx_start,
         done_o     => cmd_tx_done,
         lvds_o     => tx_o
      );
      
   cmd_crc: crc
      generic map(
         POLY_WIDTH  => CHECKSUM_BUS_WIDTH
      )
      port map(
         clk        => clk_i,
         rst        => rst_i,
         clr_i      => crc_clr,
         ena_i      => crc_ena,
         data_i     => crc_data,
         num_bits_i => crc_num_bits,
         poly_i     => "00000100110000010001110110110111", --CRC-32        
         done_o     => crc_done,
         valid_o    => crc_valid, --Dummy signal
         checksum_o => crc_checksum 
      );
      
   sh_reg: shift_reg
      generic map(
         WIDTH      => DATA_BUS_WIDTH
      )   
      port map(
         clk        => clk_i,
         rst        => rst_i,
         ena        => HIGH, --Always enabled      
         load       => crc_start,      
         clr        => LOW, --Never clear      
         shr        => HIGH, --Shift right: because the lvds_tx block shits out the least significant bit first       
         serial_i   => LOW, --Shift in low bits
         serial_o   => sh_reg_serial_o,  
         parallel_i => sh_reg_parallel_i,
         parallel_o => sh_reg_parallel_o --Dummy signal
      );

   bit_ctr: counter
      generic map(
         MAX => QUEUE_WIDTH,
         STEP_SIZE   => 1, 
         WRAP_AROUND => LOW, 
         UP_COUNTER  => HIGH        
      )
      port map(
         clk_i       => clk_i,
         rst_i       => rst_i,
         ena_i       => bit_ctr_ena,
         load_i      => crc_start,
         count_i     => INT_ZERO,
         count_o     => bit_ctr_count
      );

   -- Counter for tracking free space in the queue:
   space_calc: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         queue_space <= QUEUE_LEN;
      elsif(clk_i'event and clk_i = '1') then
         if(wren_sig = '1' and retired = '0') then
            queue_space <= queue_space - 1;
         elsif(wren_sig = '0' and retired = '1') then
            queue_space <= queue_space + 1;
         -- All other operations balance each other out
         end if;
      end if;
   end process;

   -- FSM for inserting u-ops into the u-op queue
   insert_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_insert_state <= RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_insert_state <= next_insert_state;
      end if;
   end process;

   insert_state_NS: process(present_insert_state, insert_uop_rdy, data_size_i, data_count)
   begin
      case present_insert_state is
         when RESET =>
            next_insert_state <= IDLE;
         when IDLE =>
            -- The gen_state FSM will only try to add a u-op to the queue if there is space available, so no checking is necessary here.
            -- ***This needs to react as soon as there is a u-op ready to insert..
            if(insert_uop_rdy = '1') then
               next_insert_state <= INSERT_HDR1;
            else
               next_insert_state <= IDLE;
            end if;
         when INSERT_HDR1 =>
            next_insert_state <= INSERT_HDR2;
         when INSERT_HDR2 =>
            if(data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0) = x"0000") then
--            if(data_size_int = 0) then
               next_insert_state <= DONE;
            else
               next_insert_state <= INSERT_DATA;
            end if;
         when INSERT_DATA =>
            -- INSERT_DATA state has to loop without any others in between to make sure that it records all data from the cmd_translator block
            if(data_count < data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0)) then
               next_insert_state <= INSERT_DATA;
            else
               next_insert_state <= DONE;
            end if;
         when DONE =>
            next_insert_state <= IDLE;
         when others =>
            next_insert_state <= IDLE;
      end case;
   end process;

   wraddress_sig         <= free_ptr;
   num_uops_inserted_slv <= std_logic_vector(conv_unsigned(num_uops_inserted, 8));
   
   insert_state_out: process(present_insert_state, issue_sync_i, data_size_i, new_card_addr, new_par_id, mop_i, uop_counter)
   -- There is something sketchy about the sensitivity list.  free_ptr does not appear anywhere on the list.  It can't because of my free_ptr <= free_ptr + 1 statement below.  However, it should because it appears on the lhs in the INSERT state
   begin
      case present_insert_state is
         when RESET =>
            wren_sig       <= '0';
            data_count     <= (others => '0');
            mop_ack_o      <= '0';
            insert_uop_ack <= '0';
            data_sig       <= (others => '0');
            free_ptr       <= ADDR_ZERO;
         
         when IDLE =>
            wren_sig       <= '0';
            data_count     <= (others => '0');
            mop_ack_o      <= '0';
            insert_uop_ack <= '0';
            
            data_sig       <= (others => '0');
         
         when INSERT_HDR1 =>
            wren_sig       <= '1';
            data_count     <= (others => '0');
            mop_ack_o      <= '0';
            insert_uop_ack <= '0';
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            data_sig(QUEUE_WIDTH-1      downto ISSUE_SYNC_END)   <= issue_sync_i;
            data_sig(ISSUE_SYNC_END-1   downto TIMEOUT_SYNC_END) <= issue_sync_i + TIMEOUT_LEN;
            data_sig(TIMEOUT_SYNC_END-1 downto DATA_SIZE_END)    <= data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
         
         when INSERT_HDR2 =>
            wren_sig       <= '1';
            data_count     <= (others => '0');
            
            -- Asserting mop_ack_o causes cmd_translator to begin passing data through to cmd_queue.
            -- In this implememtation, data are not replicated for other u-ops, if the m-op generates several u-ops.
            -- This means that all m-ops with data can only generate a single u-op..for now.
            -- If a m-op is issued with data and generated several u-ops, only the last one will have data.
            if(num_uops_inserted = num_uops and data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0) /= x"0000") then
               mop_ack_o   <= '1';
            else 
               mop_ack_o   <= '0';
            end if;
            
            insert_uop_ack <= '0';
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            data_sig(QUEUE_WIDTH-1      downto CARD_ADDR_END)    <= new_card_addr;
            data_sig(CARD_ADDR_END-1    downto PARAM_ID_END)     <= new_par_id;
            data_sig(PARAM_ID_END-1     downto MOP_END)          <= mop_i;
            --*** (free_ptr - 1) might be the best way to designate the u-op sequency number, instead of using num_uops_inserted
            data_sig(MOP_END-1          downto UOP_END)          <= num_uops_inserted_slv; 
            
            -- After adding new u-op header1 info, move the free_ptr
            if(free_ptr = ADDR_FULL_SCALE) then
               free_ptr <= ADDR_ZERO;
            else
               free_ptr <= free_ptr + 1;
            end if;
            
         when INSERT_DATA =>
            wren_sig       <= '1';
            data_count     <= data_count + 1;
            mop_ack_o      <= '0';
            insert_uop_ack <= '0';
            
            data_sig       <= data_i;

            -- After adding new u-op header2 info, or data:  (will this work?)
            if(free_ptr = ADDR_FULL_SCALE) then
               free_ptr <= ADDR_ZERO;
            else
               free_ptr <= free_ptr + 1;
            end if;
            
         when DONE =>
            wren_sig       <= '0';
            data_count     <= (others => '0');

            -- If there is no data with the m-op, then asserting mop_ack_o in the INSERT_HDR2 state would be too soon
            -- In this case, by delaying its assertion until DONE, we ensure that the cmd_translator doesn't try to insert the next m_op too soon.
            -- I think that I might have to register num_uops_inserted and num_uops to make sure that they are valid when I do this check
            if(num_uops_inserted = num_uops and data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0) = x"0000") then
               mop_ack_o   <= '1';
            else
               mop_ack_o   <= '0';
            end if;

            insert_uop_ack <= '1';
            data_sig       <= (others => '0');
            
            -- After adding a new u-op:
            if(free_ptr = ADDR_FULL_SCALE) then
               free_ptr <= ADDR_ZERO;
            else
               free_ptr <= free_ptr + 1;
            end if;
            
         when others =>
            wren_sig       <= '0';
            data_count     <= (others => '0');
            mop_ack_o      <= '0';
            insert_uop_ack <= '0';
            data_sig       <= (others => '0');
      end case;
   end process;

   -- Retire FSM:
   retire_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_retire_state <= RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_retire_state <= next_retire_state;
      end if;
   end process retire_state_FF;

   uop_timed_out <= '1' when (sync_count_slv > qb_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) or
                             (sync_count_slv < qb_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) and MAX_SYNC_COUNT - qb_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) + sync_count_slv > TIMEOUT_LEN)) else '0';

   retire_state_NS: process(present_retire_state, retire_ptr, send_ptr, uop_ack_i, uop_status_i, uop_timed_out)
   begin
      case present_retire_state is
         when RESET =>
            next_retire_state <= IDLE;
         when IDLE =>
            if(retire_ptr /= send_ptr) then
               next_retire_state <= NEXT_UOP;
            else
               next_retire_state <= IDLE;
            end if;
         when NEXT_UOP =>
            next_retire_state <= STATUS;
         when STATUS =>
            if(uop_ack_i = '1') then
               if(uop_status_i = SUCCESS) then
                  next_retire_state <= RETIRE;
               elsif(uop_status_i = FAIL) then
                  next_retire_state <= FLUSH;
               --Instruction timed out
               elsif(uop_timed_out = '1') then
                  next_retire_state <= EJECT;
               end if;
            elsif (uop_ack_i = '0') then
               next_retire_state <= STATUS;
            end if;
         when RETIRE =>
            next_retire_state <= IDLE;
         when FLUSH =>
            if(retire_ptr /= send_ptr) then
               next_retire_state <= NEXT_FLUSH;
            elsif(retire_ptr = send_ptr) then
               next_retire_state <= IDLE;
            end if;
         when EJECT =>
            next_retire_state <= IDLE;
         when NEXT_FLUSH =>
            next_retire_state <= FLUSH_STATUS;
         when FLUSH_STATUS =>
            if(uop_ack_i = '0') then
               next_retire_state <= FLUSH_STATUS;
            elsif(uop_ack_i = '1') then
               next_retire_state <= FLUSH;
            end if;
         when others =>
            next_retire_state <= IDLE;
      end case;
   end process;

   rdaddress_b_sig <= retire_ptr;
   uop_o <= qb_sig;

   retire_state_out: process(present_retire_state, send_ptr)
   begin
      case present_retire_state is
         when RESET =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
            uop_timedout_o <= '0';
            uop_discard_o  <= '0';
            retired        <= '0';
            retire_ptr     <= ADDR_ZERO;
            flush_ptr      <= ADDR_ZERO;
         when IDLE =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
            uop_timedout_o <= '0';
            uop_discard_o  <= '0';
            retired        <= '0';
         when NEXT_UOP =>
            uop_rdy_o      <= '1';
            freeze_send    <= '0';
            uop_timedout_o <= '0';
            uop_discard_o  <= '0';
            retired        <= '0';
         when STATUS =>
            uop_rdy_o      <= '1';
            freeze_send    <= '0';
            uop_timedout_o <= '0';
            uop_discard_o  <= '0';
            retired        <= '0';
         when RETIRE =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
            uop_timedout_o <= '0';
            uop_discard_o  <= '0';
            retired        <= '1';
            retire_ptr     <= retire_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END);
            flush_ptr      <= flush_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END);
         when FLUSH =>
            uop_rdy_o      <= '0';
            freeze_send    <= '1';
            uop_timedout_o <= '0';
            uop_discard_o  <= '1';
            retired        <= '1';
            if(retire_ptr = send_ptr) then
               -- We've finished flushing out the system of invalid u-ops
               retire_ptr <= flush_ptr;
               -- ***I can't modify the send_ptr here because it is modified in the Send FSM
               -- We need to find a way to reset the send_ptr if a flush occurs
               --send_ptr <= flush_ptr;
            end if;
         when EJECT =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
            uop_timedout_o <= '1';
            uop_discard_o  <= '1';
            retired        <= '1';
            retire_ptr     <= retire_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END);
            flush_ptr      <= flush_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END);
         when NEXT_FLUSH =>
            uop_rdy_o      <= '1';
            freeze_send    <= '1';
            uop_timedout_o <= '0';
            uop_discard_o  <= '1';
            retired        <= '0';
            -- flush_ptr acts as a place holder at this time
            retire_ptr      <= retire_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END);
         when FLUSH_STATUS =>
            uop_rdy_o      <= '1';
            freeze_send    <= '1';
            uop_timedout_o <= '0';
            uop_discard_o  <= '1';
            retired        <= '0';
         when others =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
            uop_timedout_o <= '0';
            uop_discard_o  <= '0';
            retired        <= '0';
      end case;
   end process;

   -- Generate FSM:
   gen_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_gen_state <= RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_gen_state <= next_gen_state;
      end if;
   end process;

   gen_state_NS: process(present_gen_state, mop_rdy, queue_space, size_uops, card_addr_i, 
                         insert_uop_ack, par_id_i, num_uops_inserted, num_uops)
   begin
      case present_gen_state is
         when RESET =>
            next_gen_state <= IDLE;
         when IDLE =>
            if(mop_rdy = '0') then
               next_gen_state <= IDLE;
            elsif(mop_rdy = '1') then
               -- ***This needs to be changed
               if(queue_space < size_uops) then
                  next_gen_state <= IDLE;
               elsif(queue_space >= size_uops) then
                  -- We go into CLEANUP because in this state, we set new_par_id up appropriately for insertion
                  next_gen_state <= CLEANUP;
               end if;
            end if;
         when INSERT =>
            if(insert_uop_ack = '1') then
               next_gen_state <= CLEANUP;  -- Catch all invalid card_id's with this statement
            else
               next_gen_state <= INSERT;
            end if;
         when CLEANUP =>
            -- CYC_OO_SYNC is the last u-op instruction in a RET_DAT or STATUS m-op.
            -- RET_DAT and STATUS are the only m-ops that generate u-ops with different command codes
            if(num_uops_inserted /= num_uops) then
               next_gen_state <= INSERT;
            else
               next_gen_state <= DONE;
            end if;
         when DONE =>
            next_gen_state <= IDLE;
         when others =>
            next_gen_state <= IDLE;
      end case;
   end process;

   with card_addr_i(CARD_ADDR_WIDTH-1 downto 0) select
      cards_addressed <=
         0 when NO_CARDS,
         1 when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC,
         3 when BCS,
         4 when RCS,
         9 when ALL_FPGA_CARDS,
         10 when ALL_CARDS,
         0 when others; -- invalid card address

   -- The par_id checking is done in the cmd_translator block.
   -- Thus, here I can use the 'when others' case for something other than
   -- error checking, because the par_id that cmd_translator issues to cmd_queue
   -- is always valid.
   with par_id_i(7 downto 0) select
      uops_generated <=
         6 when RET_DAT_ADDR,
         5 when STATUS_ADDR,
         1 when others; -- all other m-ops generate one u-op

   num_uops      <= uops_generated; --* cards_addressed;
   data_size_int <= conv_integer(data_size_i);
   size_uops     <= num_uops * (BB_PACKET_HEADER_SIZE + data_size_int);

   mop_rdy <= mop_rdy_i;

   gen_state_out: process(present_gen_state, card_addr_i, par_id_i) -- had new_card_addr_i
      begin
      case present_gen_state is
         when RESET =>
            insert_uop_rdy    <= '0';
            new_card_addr     <= card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0);
            uop_counter       <= (others => '0');
            num_uops_inserted <= 0;
         when IDLE =>
            insert_uop_rdy    <= '0';
            new_card_addr     <= card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0);

            new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= NULL_ADDR;
         when INSERT =>
            -- Add new u-ops to the queue
            insert_uop_rdy    <= '1';
            new_card_addr     <= card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0);
            uop_counter       <= uop_counter + 1;
            num_uops_inserted <= num_uops_inserted + 1;
         when CLEANUP =>
            insert_uop_rdy <= '0';
            new_card_addr  <= card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0);

            if(par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = RET_DAT_ADDR) then
               if(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = NULL_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= RET_DAT_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = RET_DAT_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= PSC_STATUS_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = PSC_STATUS_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= BIT_STATUS_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = BIT_STATUS_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= FPGA_TEMP_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = FPGA_TEMP_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= CARD_TEMP_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = CARD_TEMP_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= CYC_OO_SYC_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = CYC_OO_SYC_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
               end if;
            elsif(par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = STATUS_ADDR) then
               if(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = PSC_STATUS_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= BIT_STATUS_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = BIT_STATUS_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= FPGA_TEMP_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = FPGA_TEMP_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= CARD_TEMP_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = CARD_TEMP_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= CYC_OO_SYC_ADDR;
               elsif(new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = CYC_OO_SYC_ADDR) then
                  new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
               end if;
            else
               new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
            end if;
         when DONE =>
            insert_uop_rdy    <= '0';
            new_card_addr     <= card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0);
            -- uop_counter indicates the number of uops contained in the queue at any given time
            -- thus, it should not be zero'ed unless the system is reset
            num_uops_inserted <= 0;
         when others => -- Normal insertion
            insert_uop_rdy    <= '0';
            new_card_addr     <= card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0);
            -- uop_counter indicates the number of uops contained in the queue at any given time
            -- thus, it should not be zero'ed unless the system is reset
            num_uops_inserted <= 0;
      end case;
   end process;

   -- Send FSM:
   send_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_send_state <= RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_send_state <= next_send_state;
      end if;
   end process send_state_FF;

   -- issue_sync and timeout_sync need to be assigned continuously because they don't seem to update correctly inside the FSM
   -- There's something fishy about this.  
   -- The trade off with continuous assignement is that sometimes the assignment will be invalid, while send pointer is pointing at the first word of a packet
   -- That's ok, though.  I only used issue_sync and timeout_sync when they're valid.
   issue_sync       <= qa_sig(QUEUE_WIDTH-1 downto ISSUE_SYNC_END);
   timeout_sync     <= qa_sig(ISSUE_SYNC_END-1 downto TIMEOUT_SYNC_END);
   
   -- There should be enough time in the sync period following the timeout_sync of a m-op to get rid of all it's u-ops and still have time to issue the u-ops that need to be issued during that period
   -- That is why we don't check for a range here - just for the sync period that is the timeout
   -- This second conditions checks to see whether the instruction is in the black out period of the last valid sync pulse during which it can be issued.
   -- This condition won't work properly if a frame period is too short to issue a command within the correct period.
   uop_send_expired <= '1' when (sync_count_slv = timeout_sync or
                                (sync_count_slv = timeout_sync - 1 and clk_count > START_OF_BLACKOUT)) else '0';

   send_state_NS: process(present_send_state, send_ptr, free_ptr, freeze_send, uop_send_expired, 
                          issue_sync, timeout_sync, sync_count_slv, cmd_tx_done, previous_send_state, 
                          uop_data_size, uop_data_count)
   begin
      case present_send_state is
         when RESET =>
            next_send_state <= LOAD;
         when LOAD =>
            -- If there is a u-op waiting to be issued and if this FSM has not been frozen by the retire FSM, then send it or skip it.
            if(send_ptr /= free_ptr and freeze_send = '0') then
               if(uop_send_expired = '1') then
                  -- If the u-op has expired, it should be skipped
                  next_send_state <= NEXT_UOP;
               elsif(issue_sync < timeout_sync) then
                  -- Determine whether the current sync period is between the issue sync and the timeout sync.  If so, the u-op should be issued.
                  if(sync_count_slv >= issue_sync and sync_count_slv < timeout_sync) then
                     next_send_state <= HEADER_A;
                  else
                     next_send_state <= LOAD;
                  end if;
               -- The timeout_sync can have wrapped with respect to the issue_sync
               elsif(issue_sync > timeout_sync) then
                  if(sync_count_slv >= issue_sync or sync_count_slv < timeout_sync) then
                     next_send_state <= HEADER_A;
                  else
                     next_send_state <= LOAD;
                  end if;
               else
                  -- If the u-op is still good, but isn't supposed to be issued yet, stay in LOAD
                  next_send_state <= LOAD;
               end if;
            else
               next_send_state <= LOAD;
            end if;
         when HEADER_A =>
            next_send_state <= PREGNANT_PAUSE;
         when HEADER_B =>
            next_send_state <= PREGNANT_PAUSE;
         when DATA =>
            next_send_state <= PREGNANT_PAUSE;
         when MORE_DATA =>
            next_send_state <= PREGNANT_PAUSE;
         when CHECKSUM =>
            next_send_state <= PREGNANT_PAUSE;
         when PREGNANT_PAUSE =>
            -- No need to check the crc_done line because it will always be done before cmd_tx_done
            if(cmd_tx_done = '1') then -- and crc_done was '1') then            
               if(previous_send_state = HEADER_A) then
                  next_send_state <= HEADER_B;
               elsif(previous_send_state = HEADER_B) then
                  if(uop_data_size /= 0) then
                     next_send_state <= DATA;
                  else
                     next_send_state <= CHECKSUM;
                  end if;
               elsif(previous_send_state = DATA) then
                  if(uop_data_count < uop_data_size) then
                     next_send_state <= MORE_DATA;
                  else
                     next_send_state <= CHECKSUM;
                  end if;
               elsif(previous_send_state = MORE_DATA) then
                  if(uop_data_count < uop_data_size) then
                     next_send_state <= DATA;
                  else
                     next_send_state <= CHECKSUM;
                  end if;
               elsif(previous_send_state = CHECKSUM) then
                  next_send_state <= LOAD;
               end if;
            else
               next_send_state <= PREGNANT_PAUSE;
            end if;
         when NEXT_UOP =>
            -- Skip to the next u-op
            next_send_state <= LOAD;
         when others =>
            next_send_state <= LOAD;
      end case;
   end process;

   rdaddress_a_sig <= send_ptr;
   uop_data_size_int <= conv_integer(uop_data_size);

   send_state_out: process(present_send_state)
   begin
      case present_send_state is
         when RESET =>
            cmd_tx_start             <= '0';
            crc_clr                  <= '1';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            crc_num_bits             <= 0;
            uop_data_count           <= (others => '0');
            uop_data_size            <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto  0) <= (others => '0');
            sh_reg_parallel_i        <= (others => '0');
            
            previous_send_state      <= RESET;
            send_ptr                 <= ADDR_ZERO;
         
         when LOAD =>
            cmd_tx_start             <= '0';
            crc_clr                  <= '1';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            crc_num_bits             <= 0;
            uop_data_count           <= (others => '0');
            uop_data_size            <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto  0) <= (others => '0');
            sh_reg_parallel_i        <= (others => '0');
            
            previous_send_state      <= LOAD;
            
            -- I thought that I could update issue_sync and timeout_sync only when they're inputs would be valid
            -- However, I discovered that for some reason, this doesn't work.
            -- This is worth investigation.
            --issue_sync       <= qa_sig(QUEUE_WIDTH-1 downto ISSUE_SYNC_END);
            --timeout_sync     <= qa_sig(ISSUE_SYNC_END-1 downto TIMEOUT_SYNC_END);
         
         when HEADER_A =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '1';
            crc_num_bits             <= (BB_PACKET_HEADER_SIZE + uop_data_size_int)*QUEUE_WIDTH;
            uop_data_count           <= (others => '0');
            uop_data_size            <= qa_sig(TIMEOUT_SYNC_END-1 downto DATA_SIZE_END);
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto 0)  <= BB_PREAMBLE & qa_sig(TIMEOUT_SYNC_END-1 downto 0);
            sh_reg_parallel_i        <= BB_PREAMBLE & qa_sig(TIMEOUT_SYNC_END-1 downto 0);

            previous_send_state      <= HEADER_A;
            send_ptr                 <= send_ptr + 1; -- The pointer has to be incremented for the next memory location right away
         
            -- I thought that I could update issue_sync and timeout_sync only when they're inputs would be valid
            -- However, I discovered that for some reason, this doesn't work.
            -- This is worth investigation.
            --issue_sync       <= qa_sig(QUEUE_WIDTH-1 downto ISSUE_SYNC_END);
            --timeout_sync     <= qa_sig(ISSUE_SYNC_END-1 downto TIMEOUT_SYNC_END);

         when HEADER_B =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '1';
            uop_data_count           <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto 0)  <= qa_sig(QUEUE_WIDTH-1 downto 0);
            sh_reg_parallel_i        <= qa_sig(QUEUE_WIDTH-1 downto 0);

            previous_send_state      <= HEADER_B;
            send_ptr                 <= send_ptr + 1;
         
         when DATA =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '1';
            uop_data_count           <= uop_data_count + 1;
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto  0) <= qa_sig(QUEUE_WIDTH-1 downto 0);
            sh_reg_parallel_i        <= qa_sig(QUEUE_WIDTH-1 downto 0);
            
            previous_send_state      <= DATA;            
            send_ptr                 <= send_ptr + 1;
         
         when MORE_DATA =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '1';
            uop_data_count           <= uop_data_count + 1;
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto  0) <= qa_sig(QUEUE_WIDTH-1 downto 0);
            sh_reg_parallel_i        <= qa_sig(QUEUE_WIDTH-1 downto 0);

            previous_send_state      <= MORE_DATA;
            send_ptr                 <= send_ptr + 1;
         
         when CHECKSUM =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            crc_num_bits             <= 0;
            uop_data_size            <= (others => '0');
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto  0) <= crc_reg;
            sh_reg_parallel_i        <= (others => '0');
            
            previous_send_state      <= CHECKSUM;
--            send_ptr                 <= send_ptr + 1; -- The pointer is already at the next u-op
         
         when PREGNANT_PAUSE =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '0';
            --uop_data_size            <= '0';  Not to be zero'ed here.  This is an intermediate state between the HEADER, DATA and CHECKSUM states

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            sh_reg_parallel_i        <= (others => '0');

            --previous_send_state      <= PREGNANT_PAUSE;  Not to be changed here.  This variable needs to be maintained as it is through the PREGNANT_PAUSE state so that it can branch correctly in the send_state_NS FSM.
         
         when NEXT_UOP =>
            cmd_tx_start             <= '0';
            crc_clr                  <= '1';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            crc_num_bits             <= 0;
            uop_data_size            <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto  0) <= (others => '0');
            sh_reg_parallel_i        <= (others => '0');

            previous_send_state      <= NEXT_UOP;
            
            -- The send_ptr should be incremented to the next u-op if this one has expired
            send_ptr                 <= send_ptr + BB_PACKET_HEADER_SIZE + qa_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END);
         
         when others =>
            cmd_tx_start             <= '0';
            crc_clr                  <= '1';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            crc_num_bits             <= 0;
            uop_data_count           <= (others => '0');
            uop_data_size            <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat(31 downto  0) <= (others => '0');
            sh_reg_parallel_i        <= (others => '0');

            previous_send_state      <= LOAD;
      end case;
   end process;

   n_clk             <= not clk_i;
   sync_count_slv    <= std_logic_vector(conv_unsigned(sync_count_int, 8));
   
   -- CRC logic
   crc_ena           <= '1' when bit_ctr_count < 32 else '0';   
   crc_data          <= sh_reg_serial_o;
   crc_reg           <= crc_checksum when crc_done = '1' else crc_reg;

end behav;

-- Bugs:
--x The insert FSM doesn't insert the first u-op in a sequence
--  I had to adjust the order that commands are issed over the bus backplane

--x The address card should be the last card that u-ops are issued to
--  There was a problem with what signals were on the sensitivity list.  For statements like i<=i+1, i should not appear in the sensitivity list

--x The generate FSM keeps on repeating the issue of u-ops to the AC
--  Solved by deasserting mop_rdy_o after mop_ack_i returned high

--x uops issued over the bus backplane should be issued in the following order: {for each uop(for each applicable card(issue uop))}
-- Done

--x the next_gen_state change occurs one clock cycle too late
--  added last_card_uop to the gen_NS fsm sensitivity list

--x last_card_uop count wrong.
-- removed last_card_uop becuase it is not used anymore.

--x new_card_addr should change one clock cycle earlier at the beginning of a sequence of u-ops issued
--  Done

--x the generate FSM cycles over two u-ops during a u-op transition
--  Done

--x uop_counter wraps at 31.  UOP_BUS_WIDTH is only bit bits wide.
--  UOP_BUS_WIDTH and MOP_BUS_WIDTH have been widened to 8 bits each.

--x I need to widen the RAM lines to 64 bits.
--  Done.

--x Change the handshaking protocol with the cmd_translator so that the ack signal is only asserted when the cmd_queue is done receiving a m-op.
--  This is already done by the Generate FSM

--x How do I convert and integer to a std_logic_vector
-- conv_std_logic_vector(name of vector, width of vector)
-- include ieee.std_logic_unsigned.all

--x Right now, determinig whether there is enough queue_space is calculated based on the number of u-ops that are inserted
-- it should actually be calculated based on the number of u-ops and how large each u-op is.

--x Change the clock frequency for the ram block and insertion FSM to clk_i instead of fast_clk_i
-- Done but not tested

--x Figure out how to take continuous data from the cmd_translator block
-- The insert FSM can take continuous data at the normal clock frequency
-- Once it is done, it asserts insert_uop_ack to let the generate FSM know that it's ready to receive the next u-op
-- While it is inserting the u-op and data, it asserts the inserting signal to all the queue-size FSM to alter the space available in the queue
-- To begin the continuous data stream, the insert FSM asserts the mop_ack_o line directly.

--x Slow down the insertion FSM so that everything works with the same clock.
-- To do this, I will have to implement a handshaking protocol to stall the generate FSM while the insert FSM is busy
-- The handshaking protocol between insert and generate FSMs has been implemented.
-- The handshaking signals used are insert_uop_rdy and insert_uop_ack
-- These signals are used exclusively for this purpose.

--x Send FSM must send out all relevant fields in the correct order, while creating a checksum on the fly

--x Combine the packetization and send FSMs together, because they both need write access to send_ptr.

--x Disable the CRC while the lvds_tx block finishes transmission, so that the CRC block doesn't count garbage data against the CRC.  
-- We are garunteed that the CRC block will finish calculating the checksum before the lvdsl_tx finishes tx'in the data

--x The 25Mhz LVDS clk should actually be 200 Mhz

--x add the crc_ena block signal to the crc calculation block in a manner that the crc is not calculated on garbage bits.

--x Write the supporting code in the send FSM for freeze_send.

--x Check the sensitivity lists on the FSMs that I've been testing this morning.

--x The insert fsm needs to put data into the queue in a single cycle.

--x The communication between Generate FSM and Insert FSM is faulty.  
-- Generate does not wait for insert to finish before asserting the next card address

--x Think about changing the order of the packet header information
-- I have changed the order of the BB-packet fields to make it easier for the Master's to discard a packet that doesn't pertain to it
-- Now word 0 contains (Bus Backplane preamble, card address, parameter id)
-- Now word 1 contains (data size, m-op code, u-op code)
-- Actually, I just figured out that I can't do it, because I need the 'data size' field in the first word so that management of the retire pointer matches all others.
-- Data Size needs to be accessed by the retire pointer in the first index of each packet as stored in the command queue.
-- If it was in the second index of each command queue, the pointer handling would be overly complicated.
-- I would have to handle the pointer differently depending on whether the 'retire_ptr' has reached the 'free_ptr' or not
-- Ernie will have to take two pieces of data first, before he discards the rest.
-- However, Ernie doesn't need to worry about managing several u-ops at once in a single queue - only one at a time.

--x issue_sync and timeout_sync signals seem to be used both for the insert and send FSM.  
-- However, both should actually be two different signals - one to each FSM.
-- The insert FSM should get it's issue and timeout information from the cmd_translator block.
-- The send FSM should get it's issue and timeout information from the cmd_queue RAM.
-- Actually, after closer inspection, this is how it works.

--x issue_sync and timeout_sync don't seem to be getting valid values

--x mop_ack_o needs to be asserted in the DONE state if there is no data included with the m_op
-- This will allow the FSM to recover before cmd_translator can issued the next m-op, as soon as 2 clock cycles after mop_ack_o is asserted

-- Test packets with multiple data words.  I'm not sure that the insert FSM will work properly with only one state.

-- Think about using the free_ptr index to tag the u-op sequence number in the queue.

-- There's a problem with the use of the counters i've used in frame_timing and cmd_queue.  
-- They all continue on counting after they've gone past the limit that they count to.
-- The bad thing about this is that if the counter wraps after exceeding the time limit, then there could be problems.
-- The cmd_queue counter has been fixed, but I don't think that the frame_timing counter has.

-- Check out the ***'ed lines

-- Find some way to initialize the RAM to 0xFFFFFFFF

-- Check out clk_error, and figure out why it is so out of whack.  
-- It might be something to do with having a faulty period for the sync pulse in the TB.

-- The send FSM needs a way of notifying the retire fsm wheter a u-op has been skipped or not
-- NEXT_UOP in send_states should tag the uop with a special code so that the retire fsm can recognize that it was skipped.
-- I need to insert a code either in the start sync, end sync or data size field.  
-- At this point, I think that I'll use the data size field, because there are definate limits to the size that a packet will be.
-- I can't add a new state in the send state machine that would alter the data field, because you can only read from the qa_sig data port.