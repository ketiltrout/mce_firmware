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
-- $Id: cmd_queue.vhd,v 1.46 2004/08/31 21:43:13 jjacob Exp $
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
-- Revision 1.46  2004/08/31 21:43:13  jjacob
-- updating
--
-- Revision 1.45  2004/08/25 22:15:01  bburger
-- Bryce:  added a recirc mux for data_size_reg
--
-- Revision 1.44  2004/08/24 00:00:05  jjacob
-- cleaning up some comments
--
-- Revision 1.43  2004/08/23 17:36:04  jjacob
-- safety checkin.  Also, I have removed all synthesis warnings, and completed
-- adding all the recirculation muxes
--
-- Revision 1.42  2004/08/20 21:25:08  jjacob
-- commented out first_time_checker
--
-- Revision 1.41  2004/08/20 21:08:29  jjacob
-- still adding re-circulation muxes, in progress.  Packets seem fine except
-- for the checksum
--
-- Revision 1.40  2004/08/19 18:22:42  jjacob
-- merged 1.38 with 1.39.  Added re-circulation muxes to most state machines.
-- Still have to do last couple state machines
--
-- Revision 1.39  2004/08/18 06:48:43  bench2
-- Bryce: removed unnecessary interface signals between the cmd_queue and the reply_queue.
--
-- Revision 1.38  2004/08/06 00:49:15  bburger
-- Bryce:  Added a comment
--
-- Revision 1.37  2004/08/05 23:55:45  bburger
-- Bryce:  Fixed a bug in the CLEANUP state of gen_state_NS.  "num_uops_inserted < num_uops", instead of "num_uops_inserted <= num_uops".  This allows the card_addr_i and par_id_i inputs to not be changed immedately when uop_rdy goes low
--
-- Revision 1.36  2004/08/05 23:46:01  bburger
-- Bryce:  Fixed a bug in the CLEANUP state of gen_state_NS.  "num_uops_inserted <= num_uops", instead of "num_uops_inserted /= num_uops"
--
-- Revision 1.35  2004/08/05 21:17:46  bburger
-- Bryce:  Now works with the data-clocking format of fibre_rx
--
-- Revision 1.34  2004/08/05 18:40:57  bburger
-- Bryce:  In progress
--
-- Revision 1.33  2004/08/04 17:26:43  bburger
-- Bryce:  In progress
--
-- Revision 1.32  2004/08/04 17:12:44  bburger
-- Bryce:  In progress
--
-- Revision 1.31  2004/08/04 03:10:23  bburger
-- Bryce:  In progress
--
-- Revision 1.30  2004/07/31 00:13:04  bench2
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
--      uop_status_i  : in std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
      uop_rdy_o     : out std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
      uop_ack_i     : in std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
--      uop_discard_o : out std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.
--      uop_timedout_o: out std_logic; -- Tells that reply_queue that it should generated a timed-out reply based on the the par_id, card_addr, etc of the u-op being retired.
      uop_o         : out std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

      -- cmd_translator interface
      card_addr_i   : in std_logic_vector(CARD_ADDR_BUS_WIDTH-1 downto 0); -- The card address of the m-op
      par_id_i      : in std_logic_vector(PAR_ID_BUS_WIDTH-1 downto 0); -- The parameter id of the m-op
      data_size_i   : in std_logic_vector(DATA_SIZE_BUS_WIDTH-1 downto 0); -- The number of 32-bit words of data in the m-op
      data_i        : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);  -- Data belonging to a m-op
      data_clk_i    : in std_logic; -- Clocks in 32-bit wide data
      mop_i         : in std_logic_vector(MOP_BUS_WIDTH-1 downto 0); -- M-op sequence number
      issue_sync_i  : in std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0); -- The issuing sync-pulse sequence number
      mop_rdy_i     : in std_logic; -- Tells cmd_queue when a m-op is ready
      mop_ack_o     : out std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op and is ready to receive data
      
      -- lvds_tx interface
      tx_o          : out std_logic;  -- transmitter output pin
      clk_200mhz_i  : in std_logic;  -- PLL locked 25MHz input clock for the LVDS tranceivers 

      -- Clock lines
      sync_i        : in std_logic; -- The sync pulse determines when and when not to issue u-ops
      sync_num_i    : in std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);
      clk_i         : in std_logic; -- Advances the state machines
      rst_i         : in std_logic  -- Resets all FSMs
      
      -- for testing
      --cmd_tx_dat_o  : out std_logic_vector(31 downto 0)
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
--signal uop_counter          : std_logic_vector(UOP_BUS_WIDTH - 1 downto 0);

-- Sync-pulse counter inputs/outputs.  These are used to determine when u-ops have expired.
signal sync_count_slv       : std_logic_vector(7 downto 0);
--signal sync_count_int       : integer;
--signal clk_count            : integer;
--signal clk_error            : std_logic_vector(31 downto 0);

-- Command queue management variables
signal uops_generated       : integer;
signal cards_addressed      : integer;
signal num_uops             : integer;
signal data_size_int        : integer;
signal size_uops            : integer;
signal num_uops_inserted    : integer; --determines when to stop inserting u-ops
signal queue_space          : integer;

-- Command queue address pointers.  Each one of these are managed by a different FSM.
signal retire_ptr           : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal flush_ptr            : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal send_ptr             : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal free_ptr             : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);

-- Insertion FSM:  inserts u-ops into the command queue
type insert_states is (IDLE, INSERT_HDR1, INSERT_HDR2, INSERT_DATA, INSERT_MORE_DATA, DONE, RESET, DATA_STROBE_DETECT, LATCHED_DATA);
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
signal data_size_reg        : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
signal data_size_mux        : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
signal data_size_mux_sel    : std_logic;

-- Send FSM:  sends u-ops over the bus backplane
type send_states is (LOAD, ISSUE, HEADER_A, HEADER_B, DATA, MORE_DATA, CHECKSUM, NEXT_UOP, RESET, PAUSE);
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

-- [JJ]
signal queue_space_mux      : integer;
signal queue_space_mux_sel  : std_logic_vector(1 downto 0);

signal data_sig_reg         : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal data_sig_mux         : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal data_sig2            : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal data_sig_mux_sel     : std_logic_vector(1 downto 0);

signal data_count_mux       : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0); 
signal data_count_mux_sel   : std_logic_vector(1 downto 0);

signal free_ptr_mux         : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal free_ptr_mux_sel     : std_logic_vector(1 downto 0);
signal free_ptr2             : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal free_ptr_reg          : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);

signal retire_ptr_mux       : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal retire_ptr_mux_sel   : std_logic_vector(2 downto 0);

signal flush_ptr_mux        : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal flush_ptr_mux_sel    : std_logic_vector(1 downto 0);

signal current_par_id      : std_logic_vector(CQ_PAR_ID_BUS_WIDTH-1 downto 0);

signal new_par_id_mux           : std_logic_vector(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
signal new_par_id_reg           : std_logic_vector(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
signal new_par_id_mux_sel           : std_logic_vector(CQ_PAR_ID_BUS_WIDTH-1 downto 0);

constant PAR_ID             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"EE";
constant RECIRC             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"EF";

signal num_uops_inserted_mux_sel : std_logic_vector(1 downto 0);
signal num_uops_inserted_mux     : integer;
signal num_uops_inserted_reg     : integer;


type first_time_state is (IDLE, INSERT_1ST_TIME, INSERT_EXTENDED_TIME);
signal first_time_cur_state, first_time_next_state : first_time_state;

signal first_time_uop_inc       : std_logic;

signal crc_num_bits_mux_sel : std_logic_vector(1 downto 0);
signal crc_num_bits_reg     : integer;
signal crc_num_bits2        : integer;

signal cmd_tx_dat_mux_sel   : std_logic_vector(2 downto 0);
signal cmd_tx_dat_reg       : std_logic_vector(31 downto 0);
signal cmd_tx_dat2          : std_logic_vector(31 downto 0);

signal header_a_state       : std_logic;
signal first_time_header_a  : std_logic;

signal send_ptr_reg           : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal send_ptr_mux_sel       : std_logic_vector(1 downto 0);

signal uop_data_count_mux_sel : std_logic_vector(1 downto 0);
signal uop_data_count_reg     : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);

signal uop_data_size_mux_sel  : std_logic_vector(1 downto 0);
signal uop_data_size_reg      : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
signal uop_data_size2         : std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);

signal sh_reg_parallel_mux_sel: std_logic_vector(1 downto 0);

type queue_state is           (INIT1, INIT2, DONE);
signal queue_next_state, queue_cur_state : queue_state;
signal queue_init_value_sel   : std_logic;


--component first_time_tracker
--
--   port(
--   
--      clk_i                 : in std_logic;    -- Advances the state machines
--      rst_i                 : in std_logic;     -- Resets all FSMs
--
--      next_tracking_state_i : in std_logic;    -- '1' when you are in the state to track, '0' otherwise
--      
--      -- lvds_tx interface
--      first_time_o          : out std_logic  -- high by default, goes low after you have been in a state for more
--                                              -- than one clock cycle.  Once you leave that state, goes high again.
--   );
--end component;


begin

------------------------------------------------------------------------
--
-- instantiations
--
------------------------------------------------------------------------ 

   -- Command queue (FIFO)
   cmd_queue_ram40_inst: cmd_queue_ram40--_test
      port map(
         data        => data_sig,
         wraddress   => wraddress_sig,
         rdaddress_a => rdaddress_a_sig,
         rdaddress_b => rdaddress_b_sig,
         wren        => wren_sig,
         clock       => clk_200mhz_i, --n_clk,      clk_i, --   
         qa          => qa_sig, -- qa_sig data are used by the send FSM         
         qb          => qb_sig -- qb_sig data are used by the retire FSM
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
  
   -- [JJ] for testing
   --cmd_tx_dat_o  <= cmd_tx_dat;
      
   cmd_crc: crc
      generic map(
         POLY_WIDTH  => CHECKSUM_BUS_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
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
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => HIGH, --Always enabled      
         load_i     => crc_start,      
         clr_i      => LOW, --Never clear      
         shr_i      => HIGH, --Shift right: because the lvds_tx block shits out the least significant bit first       
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

------------------------------------------------------------------------
--
------------------------------------------------------------------------ 

   -- [JJ] start
   -- Counter for tracking free space in the queue:
   space_calc: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         queue_space     <= QUEUE_LEN;
         queue_cur_state <= INIT1;
      elsif(clk_i'event and clk_i = '1') then
         queue_space     <= queue_space_mux;
         queue_cur_state <= queue_next_state;
      end if;
   end process;
   
   queue_space_mux <= queue_space     when queue_space_mux_sel = "00" else
                      queue_space + 1 when queue_space_mux_sel = "01" else
                      queue_space - 1 when queue_space_mux_sel = "10" else
                      QUEUE_LEN;   -- when queue_space_mux_sel = "11";
                        
   queue_space_mux_sel <= "11" when queue_init_value_sel = '1' else wren_sig & retired;
   -- [JJ] end                   

   -- initialization logic for queue_space to set it to 255 on startup
   process(queue_cur_state)
   begin
      case queue_cur_state is
         when INIT1  =>
            queue_next_state     <= INIT2;
            queue_init_value_sel <= '1';
         when INIT2  =>
            queue_next_state     <= DONE;
            queue_init_value_sel <= '1';
         when DONE   =>
            queue_next_state     <= DONE;
            queue_init_value_sel <= '0';
         when others =>
            queue_next_state     <= DONE;
            queue_init_value_sel <= '0';
      end case;
   end process;


------------------------------------------------------------------------
--
-- FSM for inserting u-ops into the u-op queue
--
------------------------------------------------------------------------ 

   insert_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_insert_state <= IDLE;--RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_insert_state <= next_insert_state;
      end if;
   end process;

   insert_state_NS: process(present_insert_state, data_size_i, data_count, data_clk_i, insert_uop_rdy)--,mop_rdy_i
   begin
      case present_insert_state is
--         when RESET =>
--            next_insert_state <= IDLE;
         when IDLE =>
            -- The gen_state FSM will only try to add a u-op to the queue if there is space available, so no checking is necessary here.
            --if( mop_rdy_i = '1') then
            if(insert_uop_rdy = '1') then
               next_insert_state <= INSERT_HDR1;
            else
               next_insert_state <= IDLE;
            end if;
         when INSERT_HDR1 =>
            next_insert_state <= INSERT_HDR2;
         when INSERT_HDR2 =>
            if(data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0) = x"0000") then
               next_insert_state <= DONE;
            else
               next_insert_state <= DATA_STROBE_DETECT;
            end if;
         when DATA_STROBE_DETECT =>
            if(data_clk_i = '1') then
               next_insert_state <= LATCHED_DATA;
            else
               next_insert_state <= DATA_STROBE_DETECT;
            end if;
         when LATCHED_DATA =>
            if(data_count < data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0)) then
               next_insert_state <= DATA_STROBE_DETECT;
            else
               next_insert_state <= DONE;
            end if;
-- This portion of the code was removed, because David's block does not transmit data on consecutive clock cycles after mop_ack_o is asserted
-- Instead, his block outputs a data strobe that is the width of an entire clock cycle.  
-- The data strobe is not garanteed to occur on the clock cycle following the assertion of mop_ack_o
-- The data strobe seems to be asserted for only one clock cycle, after which it is deasserted for two before being reasserted with new data
--         when INSERT_DATA =>
--            -- INSERT_DATA state has to loop without any others in between to make sure that it records all data from the cmd_translator block
--            if(data_count < data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0)) then
--               next_insert_state <= INSERT_MORE_DATA;
--            else
--               next_insert_state <= DONE;
--            end if;
--         when INSERT_MORE_DATA =>
--            if(data_count < data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0)) then
--               next_insert_state <= INSERT_DATA;
--            else
--               next_insert_state <= DONE;
--            end if;
         when DONE =>
            next_insert_state <= IDLE;
         when others =>
            next_insert_state <= IDLE;
      end case;
   end process;

   wraddress_sig         <= free_ptr;
   num_uops_inserted_slv <= std_logic_vector(conv_unsigned(num_uops_inserted, 8));
  


   -- data_sig routing mux
   process(data_sig_mux_sel, issue_sync_i, data_size_i, new_card_addr, new_par_id, mop_i, num_uops_inserted_slv, data_i)
   begin
      case data_sig_mux_sel is
         when "00" => data_sig_mux <=(others=>'0');
         when "01" => data_sig_mux <=(issue_sync_i & (issue_sync_i + TIMEOUT_LEN) & data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0));
         when "10" => data_sig_mux <=(new_card_addr & new_par_id & mop_i & num_uops_inserted_slv);
         when others => data_sig_mux <= data_i;
      end case;
   end process;
                     
   data_sig <= data_sig_mux;
                     
------------------------------------------------------------------------
--
-- re-circulation muxes
--
------------------------------------------------------------------------   
                     
   data_count_mux <= data_count      when data_count_mux_sel = "00" else
                     data_count + 1  when data_count_mux_sel = "01" else
                     (others => '0'); --when data_count_mux_sel = "11" else
     
                       
   free_ptr        <= free_ptr_reg       when free_ptr_mux_sel = "00" else
                      free_ptr_reg + 1   when free_ptr_mux_sel = "01" else
                      ADDR_ZERO;      --when free_ptr_mux_sel = "11";
                      
   data_size_mux  <= data_size_reg when data_size_mux_sel = '0' else data_size_i(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);   
                      

   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         --data_sig_reg   <= (others=>'0');
         data_count <= (others=>'0');
         free_ptr_reg   <= (others=>'0');
         data_size_reg  <= (others => '0');
      elsif clk_i'event and clk_i = '1' then
         --data_sig_reg   <= data_sig_mux;
         data_count <= data_count_mux;
         free_ptr_reg   <= free_ptr;
         data_size_reg  <= data_size_mux;
      end if;
   end process;



   
   insert_state_out: process(present_insert_state, data_clk_i, free_ptr, num_uops_inserted, num_uops, data_size_reg)--, issue_sync_i, new_card_addr, new_par_id, 
   
   -- There is something sketchy about the sensitivity list.  
   -- free_ptr does not appear anywhere on the list.  
   -- It can't because of my free_ptr <= free_ptr + 1 statement below.  
   -- However, it should because it appears on the lhs in the INSERT state
   
   -- [JJ] free_ptr issue is fixed
   begin
   
      --defaults
      data_sig_mux_sel             <= "00"; -- (others=>'0')
      data_count_mux_sel           <= "00";
      free_ptr_mux_sel             <= "00";
      data_size_mux_sel            <=  '0'; -- hold value

      case present_insert_state is
--         when RESET =>
--            wren_sig               <= '0';
--            data_count_mux_sel     <= "11";
--            mop_ack_o              <= '0';
--            insert_uop_ack         <= '0';
--
--            free_ptr_mux_sel       <= "11";
         
         when IDLE =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "11"; -- default
            mop_ack_o             <= '0';
            
            
            insert_uop_ack         <= '0';
            

            free_ptr_mux_sel       <= "00";
         
         when INSERT_HDR1 =>
            wren_sig               <= '1';
            data_count_mux_sel     <= "11";

            
            mop_ack_o             <= '0';
            
            insert_uop_ack         <= '0';
            
            data_sig_mux_sel       <= "01";
--            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line

            free_ptr_mux_sel       <= "00";
            
            data_size_mux_sel      <=  '1';

         when INSERT_HDR2 =>
            wren_sig               <= '1';
            data_count_mux_sel     <= "11";
            
            -- Asserting mop_ack_o causes cmd_translator to begin passing data through to cmd_queue.
            -- In this implememtation, data are not replicated for other u-ops, if the m-op generates several u-ops.
            -- This means that all m-ops with data can only generate a single u-op..for now.
            -- If a m-op is issued with data and generated several u-ops, only the last one will have data.
            if(num_uops_inserted = num_uops and data_size_reg /= x"0000") then
               mop_ack_o          <= '1';
               
            else 
               mop_ack_o          <= '0';
            end if;
            
            insert_uop_ack         <= '0';
            
            data_sig_mux_sel       <= "10";
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line

--            --*** (free_ptr - 1) might be the best way to designate the u-op sequence number, instead of using num_uops_inserted
            
            -- After adding new u-op header1 info, move the free_ptr
            free_ptr_mux_sel       <= "01";
            
         when DATA_STROBE_DETECT =>
            if(data_clk_i = '1') then
               wren_sig            <= '1';
               data_count_mux_sel  <= "01";
               --data_count          <= data_count + 1;
               mop_ack_o          <= '0';
               insert_uop_ack      <= '0';
               
               data_sig_mux_sel    <= "11";
   
               -- After adding new u-op header2 info, or data:  (will this work?)
               free_ptr_mux_sel    <= "01";

            else
               wren_sig            <= '0';
               data_count_mux_sel  <= "00";

               mop_ack_o          <= '0';
               insert_uop_ack      <= '0';
               
               data_sig_mux_sel    <= "11";
  
               free_ptr_mux_sel    <= "00";

            end if;
         when LATCHED_DATA =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "00";

            mop_ack_o             <= '0';
            insert_uop_ack         <= '0';
            
            data_sig_mux_sel       <= "11";
            
            free_ptr_mux_sel       <= "00";


         when DONE =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "11";
            --data_count             <= (others => '0');

            -- If there is no data with the m-op, then asserting mop_ack_o in the INSERT_HDR2 state would be too soon
            -- In this case, by delaying its assertion until DONE, we ensure that the cmd_translator doesn't try to insert the next m_op too soon.
            -- I think that I might have to register num_uops_inserted and num_uops to make sure that they are valid when I do this check
            if(num_uops_inserted = num_uops and data_size_reg = x"0000") then
               mop_ack_o          <= '1';
               
            else
               mop_ack_o          <= '0';
            end if;

            insert_uop_ack         <= '1';
            data_sig_mux_sel       <= "00";
            
            -- After adding a new u-op:
            if(free_ptr = ADDR_FULL_SCALE) then
               free_ptr_mux_sel    <= "11";
            else
               free_ptr_mux_sel    <= "01";
            end if;
            
         when others =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "11";

            mop_ack_o             <= '0';
            insert_uop_ack         <= '0';
            data_sig_mux_sel       <= "00";

            free_ptr_mux_sel       <= "00";
      end case;
   end process;


   -- Retire FSM:
   retire_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_retire_state <= IDLE;--RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_retire_state <= next_retire_state;
      end if;
   end process retire_state_FF;

   uop_timed_out <= '1' when (sync_count_slv > qb_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) or
                             (sync_count_slv < qb_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) and 
                              MAX_SYNC_COUNT - qb_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) + 
                              sync_count_slv > TIMEOUT_LEN))
                              else '0';

   retire_state_NS: process(present_retire_state, retire_ptr, send_ptr, uop_ack_i)--, uop_timed_out)
   begin
      case present_retire_state is
--         when RESET =>
--            next_retire_state <= IDLE;
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
--               if(uop_status_i = SUCCESS) then
                  next_retire_state <= RETIRE;
--               elsif(uop_status_i = FAIL) then
--                  next_retire_state <= FLUSH;
--               --Instruction timed out
--               elsif(uop_timed_out = '1') then
--                  next_retire_state <= EJECT;
--               end if;
            elsif (uop_ack_i = '0') then
               next_retire_state <= STATUS;
            end if;
         when RETIRE =>
            next_retire_state <= IDLE;
-- I have commented out all these extra states because the cmd_queue should not control of retiring u-ops.
-- Only the reply_queue should have this abilty.
-- The reply_queue takes on the responsibility of detecting errors so that the cmd_queue does not.
-- Thus the cmd_queue need only know when to retire a u-op regardless of whether its reply is ok or in error.
--         when FLUSH =>
--            if(retire_ptr /= send_ptr) then
--               next_retire_state <= NEXT_FLUSH;
--            elsif(retire_ptr = send_ptr) then
--               next_retire_state <= IDLE;
--            end if;
--         when EJECT =>
--            next_retire_state <= IDLE;
--         when NEXT_FLUSH =>
--            next_retire_state <= FLUSH_STATUS;
--         when FLUSH_STATUS =>
--            if(uop_ack_i = '0') then
--               next_retire_state <= FLUSH_STATUS;
--            elsif(uop_ack_i = '1') then
--               next_retire_state <= FLUSH;
--            end if;
         when others =>
            next_retire_state <= IDLE;
      end case;
   end process;

   rdaddress_b_sig <= retire_ptr;
   uop_o <= qb_sig;



   retire_state_out: process(present_retire_state)--, send_ptr, retire_ptr)
   begin
      -- defaults
      retire_ptr_mux_sel <= "000"; -- hold value
      flush_ptr_mux_sel  <= "00";  -- hold value
   
      case present_retire_state is
--         when RESET =>
--            uop_rdy_o      <= '0';
--            freeze_send    <= '0';
----            uop_timedout_o <= '0';
----            uop_discard_o  <= '0';
--            retired        <= '0';
--            retire_ptr_mux_sel <= "001";
--            
--            flush_ptr_mux_sel  <= "01";
         when IDLE =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '0';
            retired        <= '0';
            
         when NEXT_UOP =>
            uop_rdy_o      <= '1';
            freeze_send    <= '0';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '0';
            retired        <= '0';
            
         when STATUS =>
            uop_rdy_o      <= '1';
            freeze_send    <= '0';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '0';
            retired        <= '0';
            
         when RETIRE =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '0';
            retired        <= '1';

            
            retire_ptr_mux_sel <= "010";
 
            flush_ptr_mux_sel  <= "10";

--         when FLUSH =>
--            uop_rdy_o      <= '0';
--            freeze_send    <= '1';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '1';
--            retired        <= '1';
--            if(retire_ptr = send_ptr) then
--               -- We've finished flushing out the system of invalid u-ops
--               retire_ptr_mux_sel <= "011";
--
--               -- ***I can't modify the send_ptr here because it is modified in the Send FSM
--               -- We need to find a way to reset the send_ptr if a flush occurs
--
--            end if;
--         when EJECT =>
--            uop_rdy_o      <= '0';
--            freeze_send    <= '0';
--            uop_timedout_o <= '1';
--            uop_discard_o  <= '1';
--            retired        <= '1';
--            retire_ptr_mux_sel <= "100";
--            
--            flush_ptr_mux_sel  <= "10";
--
--         when NEXT_FLUSH =>
--            uop_rdy_o      <= '1';
--            freeze_send    <= '1';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '1';
--            retired        <= '0';
--            -- flush_ptr acts as a place holder at this time
--            retire_ptr_mux_sel <= "010";
--
--         when FLUSH_STATUS =>
--            uop_rdy_o      <= '1';
--            freeze_send    <= '1';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '1';
--            retired        <= '0';

         when others =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
--            uop_timedout_o <= '0';
--            uop_discard_o  <= '0';
            retired        <= '0';
      end case;
   end process;

------------------------------------------------------------------------
--
-- re-circulation muxes
--
------------------------------------------------------------------------

   retire_ptr_mux <= retire_ptr when retire_ptr_mux_sel = "000" else
                     ADDR_ZERO  when retire_ptr_mux_sel = "001" else
                     retire_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END) when retire_ptr_mux_sel = "010" else
                     flush_ptr when retire_ptr_mux_sel = "011" else
                     flush_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END); --when retire_ptr_mux_sel = "100" else
   
   flush_ptr_mux <=  flush_ptr when flush_ptr_mux_sel  = "00" else
                     ADDR_ZERO when flush_ptr_mux_sel  = "01" else
                     flush_ptr + BB_PACKET_HEADER_SIZE + qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END); -- when "10"
                     
                     
   process(rst_i, clk_i)                
   begin
      if rst_i = '1' then 
         retire_ptr <= (others=>'0');
         flush_ptr  <= (others=>'0');
      elsif clk_i'event and clk_i = '1' then
         retire_ptr <= retire_ptr_mux;
         flush_ptr  <= flush_ptr_mux;
      end if;
   end process;



------------------------------------------------------------------------
--
-- Generate FSM:
--
------------------------------------------------------------------------
   
   gen_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_gen_state <= IDLE;--RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_gen_state <= next_gen_state;
      end if;
   end process;

   gen_state_NS: process(present_gen_state, mop_rdy, queue_space, size_uops,  
                         insert_uop_ack, num_uops_inserted, num_uops)--card_addr_i, par_id_i, 
   begin
   
   -- [JJ] test: default
  -- mop_ack_o           <= '0';
   
      case present_gen_state is
--         when RESET =>
--            next_gen_state <= IDLE;
         when IDLE =>
            if(mop_rdy = '0') then
               next_gen_state <= IDLE;
            else   
               if(queue_space >= size_uops) then
                  next_gen_state <= CLEANUP;
                  
               else
                  next_gen_state <= IDLE;
               end if;            
            
            --elsif(mop_rdy = '1') then
--               if(queue_space < size_uops) then
--                  next_gen_state <= IDLE;
--                  mop_ack_o           <= '1';
--               else
--               --elsif(queue_space >= size_uops) then
--                  -- We go into CLEANUP because in this state, we set new_par_id up appropriately for insertion
--                  next_gen_state <= CLEANUP;
--                  --mop_ack_o           <= '1';
--               end if;
            end if;
         when INSERT =>
            if(insert_uop_ack = '1') then
               next_gen_state <= CLEANUP;  -- Catch all invalid card_id's with this statement
            else
               next_gen_state <= INSERT;
             --  mop_ack_o           <= '1';
            end if;
         when CLEANUP =>
            -- CYC_OO_SYNC is the last u-op instruction in a RET_DAT or STATUS m-op.
            -- RET_DAT and STATUS are the only m-ops that generate u-ops with different command codes
            -- ***
            if(num_uops_inserted < num_uops) then
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

   new_card_addr     <= card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0);


   -- state sequencer to keep track of first time entering a state for incrementing
   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         first_time_cur_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         first_time_cur_state <= first_time_next_state;
      end if;
   end process;

   -- assign output
   process(first_time_cur_state)
   begin
      case first_time_cur_state is
         when IDLE                 => first_time_uop_inc <= '1';
         when INSERT_1ST_TIME      => first_time_uop_inc <= '1';
         when INSERT_EXTENDED_TIME => first_time_uop_inc <= '0';
         when others               => first_time_uop_inc <= '1';
      end case;
   end process;
   
   -- assign next_state
   process(first_time_cur_state, next_gen_state)
   begin
      case first_time_cur_state is
         when IDLE =>
            if next_gen_state = INSERT then
               first_time_next_state <= INSERT_1ST_TIME;
            else
               first_time_next_state <= IDLE;
            end if;
            
         when INSERT_1ST_TIME =>
            if next_gen_state = INSERT then
               first_time_next_state <= INSERT_EXTENDED_TIME;
            else
               first_time_next_state <= IDLE;
            end if;
            
         when INSERT_EXTENDED_TIME =>
            if next_gen_state = INSERT then
               first_time_next_state <= INSERT_EXTENDED_TIME;
            else
               first_time_next_state <= IDLE;
            end if;
            
         when others => first_time_next_state <= IDLE;
         
      end case;
   end process;


   gen_state_out: process(present_gen_state, par_id_i, current_par_id, first_time_uop_inc)
      begin
      
      -- default
      new_par_id_mux_sel                 <= RECIRC;
      num_uops_inserted_mux_sel          <= "00"; --recirculate, hold value
      
      case present_gen_state is
--         when RESET =>
--            insert_uop_rdy               <= '0';
--            
--            num_uops_inserted_mux_sel    <= "10"; -- '0'
--            new_par_id_mux_sel           <= NULL_ADDR;
            
         when IDLE =>
            insert_uop_rdy               <= '0';

            new_par_id_mux_sel           <= NULL_ADDR;
         when INSERT =>
            -- Add new u-ops to the queue
            insert_uop_rdy               <= '1';
            
            if first_time_uop_inc = '1' then
               num_uops_inserted_mux_sel <= "01"; -- + 1
            else
               num_uops_inserted_mux_sel <= "00"; -- hold
            end if;
            
         when CLEANUP =>
            insert_uop_rdy               <= '0';

           if(par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = RET_DAT_ADDR) then
               case current_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) is
                  when NULL_ADDR       => new_par_id_mux_sel <= RET_DAT_ADDR;
                  when RET_DAT_ADDR    => new_par_id_mux_sel <= PSC_STATUS_ADDR;
                  when PSC_STATUS_ADDR => new_par_id_mux_sel <= BIT_STATUS_ADDR;
                  when BIT_STATUS_ADDR => new_par_id_mux_sel <= FPGA_TEMP_ADDR;
                  when FPGA_TEMP_ADDR  => new_par_id_mux_sel <= CARD_TEMP_ADDR;
                  when CARD_TEMP_ADDR  => new_par_id_mux_sel <= CYC_OO_SYC_ADDR;
                  when CYC_OO_SYC_ADDR => new_par_id_mux_sel <= PAR_ID;
                  when others          => new_par_id_mux_sel <= RECIRC;
               end case;
               
            elsif(par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0) = STATUS_ADDR) then
               case current_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) is
                  when PSC_STATUS_ADDR => new_par_id_mux_sel <= BIT_STATUS_ADDR;
                  when BIT_STATUS_ADDR => new_par_id_mux_sel <= FPGA_TEMP_ADDR;
                  when FPGA_TEMP_ADDR  => new_par_id_mux_sel <= CARD_TEMP_ADDR;
                  when CARD_TEMP_ADDR  => new_par_id_mux_sel <= CYC_OO_SYC_ADDR;
                  when CYC_OO_SYC_ADDR => new_par_id_mux_sel <= PAR_ID;
                  when others          => new_par_id_mux_sel <= RECIRC;
               end case;

            else
               new_par_id_mux_sel        <= PAR_ID;
            end if;


         when DONE =>
            insert_uop_rdy               <= '0';
            -- uop_counter indicates the number of uops contained in the queue at any given time
            -- thus, it should not be zero'ed unless the system is reset
            num_uops_inserted_mux_sel    <= "10"; -- '0'
            
         when others => -- Normal insertion
            insert_uop_rdy               <= '0';
            -- uop_counter indicates the number of uops contained in the queue at any given time
            -- thus, it should not be zero'ed unless the system is reset
            num_uops_inserted_mux_sel    <= "10"; -- '0'
            
      end case;
   end process;

   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= NULL_ADDR;
         num_uops_inserted_reg                          <= 0;

      elsif clk_i'event and clk_i = '1' then
         current_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0) <= new_par_id(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
         num_uops_inserted_reg                          <= num_uops_inserted;

      end if;
   end process;

   with num_uops_inserted_mux_sel select
      num_uops_inserted <=
         num_uops_inserted_reg     when "00",
         num_uops_inserted_reg + 1 when "01",
         0                         when others;
   
   
   with new_par_id_mux_sel select
      new_par_id <=
         RET_DAT_ADDR                                    when RET_DAT_ADDR,
         PSC_STATUS_ADDR                                 when PSC_STATUS_ADDR,
         BIT_STATUS_ADDR                                 when BIT_STATUS_ADDR,
         FPGA_TEMP_ADDR                                  when FPGA_TEMP_ADDR,
         CARD_TEMP_ADDR                                  when CARD_TEMP_ADDR,
         CYC_OO_SYC_ADDR                                 when CYC_OO_SYC_ADDR,
         par_id_i(CQ_PAR_ID_BUS_WIDTH-1 downto 0)        when PAR_ID, --0xEE
         current_par_id                                  when RECIRC, --0xEF
         current_par_id                                  when others;



   -- Send FSM:
   send_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_send_state <= LOAD;--RESET;
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
   -- This second condition checks to see whether the instruction is in the black out period of the last valid sync pulse during which it can be issued.
   -- This condition won't work properly if a frame period is too short to issue a command within the correct period.
   -- I have removed the second condition for the time being, because on a regular basis, there won't be time to re-issue commands during the same frame-period.
   -- Thus, u-op will not be re-issued if they were erroneous the first time.
   -- The concept of START_OF_BLACKOUT had been added to forsee the possibility of re-issuing u-ops during the same frame
   -- The idea was that there would always be enough time in a frame to send one set of data-taking u-ops during a frame, but there wouldn't be enough time for an unlimited number of retries
   -- The start START_OF_BLACKOUT period would basically denote the time in the frame at which it would be too late to re-start transmitting all the u-ops associated with taking data.
   -- There is also a problem with the second condition, in that if the clk_count has slipped to the end of the previous frame when the sync pulse arrives, then clk_count > START_OF_BLACKOUT.  
   -- We need something different here.
   -- Something like:  '1' when (abs_value((END_OF_FRAME - clk_count) < something) else '0';
   uop_send_expired <= '1' when (sync_count_slv = timeout_sync) else '0';
   --                          or (sync_count_slv = timeout_sync - 1 and clk_count > START_OF_BLACKOUT)) else '0';

   send_state_NS: process(present_send_state, send_ptr, free_ptr, freeze_send, uop_send_expired, 
                          issue_sync, timeout_sync, sync_count_slv, cmd_tx_done, previous_send_state, 
                          uop_data_size, uop_data_count)
   begin
      case present_send_state is
--         when RESET =>
--            next_send_state <= LOAD;
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
            next_send_state <= PAUSE;
         when HEADER_B =>
            next_send_state <= PAUSE;
         when DATA =>
            next_send_state <= PAUSE;
         when MORE_DATA =>
            next_send_state <= PAUSE;
         when CHECKSUM =>
            next_send_state <= PAUSE;
         when PAUSE =>
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
               next_send_state <= PAUSE;
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
   
      -- defaults
      crc_num_bits_mux_sel     <= "00";  -- hold value
      cmd_tx_dat_mux_sel       <= "000"; -- hold value
      send_ptr_mux_sel         <= "00";  -- hold value
      uop_data_count_mux_sel   <= "00";  -- hold value
      uop_data_size_mux_sel    <= "00";  -- hold value
      
      sh_reg_parallel_mux_sel  <= "00";  -- (others => '0');
   
      case present_send_state is
--         when RESET =>
--            cmd_tx_start             <= '0';
--            crc_clr                  <= '1';
--            bit_ctr_ena              <= '0';
--            crc_start                <= '0';
--            
--            crc_num_bits_mux_sel     <= "10";
--            --crc_num_bits             <= 0;
--            
--            uop_data_count_mux_sel   <= "11"; -- (others => '0')
--            --uop_data_count           <= (others => '0');
--            
--            uop_data_size_mux_sel    <= "11";  -- (others => '0')
--            --uop_data_size            <= (others => '0');
--
--            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
--            cmd_tx_dat_mux_sel       <= "100";  -- 0
--            
--            --cmd_tx_dat(31 downto  0) <= (others => '0');
--            
--            
--            --sh_reg_parallel_i        <= (others => '0');
--            
--            previous_send_state      <= RESET;
--            
--            send_ptr_mux_sel         <= "11"; --ADDR_ZERO
--            --send_ptr                 <= ADDR_ZERO;
         
         when LOAD =>
            cmd_tx_start             <= '0';
            crc_clr                  <= '1';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            
            crc_num_bits_mux_sel     <= "10";
            --crc_num_bits             <= 0;
            
            uop_data_count_mux_sel   <= "11";  -- (others => '0')
            --uop_data_count           <= (others => '0');
            
            uop_data_size_mux_sel    <= "11";  -- (others => '0')
            --uop_data_size            <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat_mux_sel       <= "100";  -- 0
            
            --cmd_tx_dat(31 downto  0) <= (others => '0');
            
            --sh_reg_parallel_i        <= (others => '0');
            
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
            
            crc_num_bits_mux_sel     <= "01";
            --crc_num_bits             <= (BB_PACKET_HEADER_SIZE + uop_data_size_int)*QUEUE_WIDTH;
            
            uop_data_count_mux_sel   <= "11";  -- (others => '0')
            --uop_data_count           <= (others => '0');
            
            uop_data_size_mux_sel    <= "10";  -- qa_sig(TIMEOUT_SYNC_END-1 downto DATA_SIZE_END)
            --uop_data_size            <= qa_sig(TIMEOUT_SYNC_END-1 downto DATA_SIZE_END);
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            --if first_time_header_a = '1' then
               cmd_tx_dat_mux_sel    <= "001";  -- BB_PREAMBLE & qa_sig
            --else
            --   cmd_tx_dat_mux_sel    <= "000";  -- recirculate [JJ] implement another 'first time' state machine
            --end if;  
            
            
            --cmd_tx_dat(31 downto 0)  <= BB_PREAMBLE & qa_sig(TIMEOUT_SYNC_END-1 downto 0);
            
            sh_reg_parallel_mux_sel  <= "01";  -- BB_PREAMBLE & qa_sig(TIMEOUT_SYNC_END-1 downto 0);
            --sh_reg_parallel_i        <= BB_PREAMBLE & qa_sig(TIMEOUT_SYNC_END-1 downto 0);

            previous_send_state      <= HEADER_A;
            --send_ptr                 <= send_ptr + 1; -- The pointer has to be incremented for the next memory location right away
         
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
            
            uop_data_count_mux_sel   <= "11";  -- (others => '0')
            --uop_data_count           <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat_mux_sel       <= "010";  -- qa_sig
            
            --cmd_tx_dat(31 downto 0)  <= qa_sig(QUEUE_WIDTH-1 downto 0);
            
            sh_reg_parallel_mux_sel  <= "10";  -- qa_sig(QUEUE_WIDTH-1 downto 0)
            --sh_reg_parallel_i        <= qa_sig(QUEUE_WIDTH-1 downto 0);

            previous_send_state      <= HEADER_B;
            send_ptr_mux_sel         <= "01"; --send_ptr + 1
            --send_ptr                 <= send_ptr + 1;
         
         when DATA =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '1';
            
            uop_data_count_mux_sel   <= "01";  -- uop_data_count + 1
            --uop_data_count           <= uop_data_count + 1;
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat_mux_sel       <= "010";  -- qa_sig
            
            --cmd_tx_dat(31 downto  0) <= qa_sig(QUEUE_WIDTH-1 downto 0);
            
            sh_reg_parallel_mux_sel  <= "10";  -- qa_sig(QUEUE_WIDTH-1 downto 0)
            --sh_reg_parallel_i        <= qa_sig(QUEUE_WIDTH-1 downto 0);
            
            previous_send_state      <= DATA; 
            
            send_ptr_mux_sel         <= "01"; --send_ptr + 1           
            --send_ptr                 <= send_ptr + 1;
         
         when MORE_DATA =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '1';
            
            uop_data_count_mux_sel   <= "01";  -- uop_data_count + 1
            --uop_data_count           <= uop_data_count + 1;
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat_mux_sel       <= "010";  -- qa_sig
            
            --cmd_tx_dat(31 downto  0) <= qa_sig(QUEUE_WIDTH-1 downto 0);
            
            sh_reg_parallel_mux_sel  <= "10";  -- qa_sig(QUEUE_WIDTH-1 downto 0)
            --sh_reg_parallel_i        <= qa_sig(QUEUE_WIDTH-1 downto 0);

            previous_send_state      <= MORE_DATA;
            
            send_ptr_mux_sel         <= "01"; --send_ptr + 1
            --send_ptr                 <= send_ptr + 1;
         
         when CHECKSUM =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            
            crc_num_bits_mux_sel     <= "10";
            --crc_num_bits             <= 0;
            
            uop_data_size_mux_sel    <= "11";  -- (others => '0')
            --uop_data_size            <= (others => '0');
            
            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat_mux_sel       <= "011";  -- crc_reg
            
            --cmd_tx_dat(31 downto  0) <= crc_reg;
            
            
            --sh_reg_parallel_i        <= (others => '0');
            
            previous_send_state      <= CHECKSUM;
            
            send_ptr_mux_sel         <= "01"; --send_ptr + 1
            --send_ptr                 <= send_ptr + 1; -- The pointer is already at the next u-op
         
         when PAUSE =>
            cmd_tx_start             <= '1';
            crc_clr                  <= '0';
            bit_ctr_ena              <= '1';
            crc_start                <= '0';
            ----uop_data_size            <= '0';  Not to be zero'ed here.  This is an intermediate state between the HEADER, DATA and CHECKSUM states

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            
            --sh_reg_parallel_i        <= (others => '0');

            --previous_send_state      <= PAUSE;  Not to be changed here.  This variable needs to be maintained as it is through the PAUSE state so that it can branch correctly in the send_state_NS FSM.
         
         when NEXT_UOP =>
            cmd_tx_start             <= '0';
            crc_clr                  <= '1';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            
            crc_num_bits_mux_sel     <= "10";
            --crc_num_bits             <= 0;
            
            uop_data_size_mux_sel    <= "11";  -- (others => '0')
            --uop_data_size            <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat_mux_sel       <= "100";  -- 0
            
            --cmd_tx_dat(31 downto  0) <= (others => '0');
            
            --sh_reg_parallel_i        <= (others => '0');

            previous_send_state      <= NEXT_UOP;
            
            -- The send_ptr should be incremented to the next u-op if this one has expired
            send_ptr_mux_sel         <= "10"; --send_ptr + other signals
            --send_ptr                 <= send_ptr + BB_PACKET_HEADER_SIZE + qa_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END);
         
         when others =>
            cmd_tx_start             <= '0';
            crc_clr                  <= '1';
            bit_ctr_ena              <= '0';
            crc_start                <= '0';
            
            crc_num_bits_mux_sel     <= "10";
            --crc_num_bits             <= 0;
            
            uop_data_count_mux_sel   <= "11";  -- (others => '0')
            --uop_data_count           <= (others => '0');
            
            uop_data_size_mux_sel    <= "11";  -- (others => '0')
            --uop_data_size            <= (others => '0');

            -- Queue data:  see cmd_queue_ram40_pack for details on the fields embedded in a RAM line
            cmd_tx_dat_mux_sel       <= "100";  -- 0
            
            --cmd_tx_dat(31 downto  0) <= (others => '0');
            
            --sh_reg_parallel_i        <= (others => '0');

            previous_send_state      <= LOAD;
      end case;
   end process;


--   header_a_state <= '1' when next_send_state = HEADER_A else '0';
--   
--   i_first_time_tracker : first_time_tracker
--   port map(
--   
--      clk_i                 => clk_i,
--      rst_i                 => rst_i,
--
--      next_tracking_state_i => header_a_state,
--      
--      first_time_o          => first_time_header_a 
--                                             
--   );

------------------------------------------------------------------------
--
-- recirculation muxes/ routing muxes
--
------------------------------------------------------------------------ 

    with sh_reg_parallel_mux_sel select
       sh_reg_parallel_i <= 
       (others=>'0')                                           when "00",
       BB_PREAMBLE & qa_sig(TIMEOUT_SYNC_END-1 downto 0)       when "01",
       qa_sig(QUEUE_WIDTH-1 downto 0)                          when others; --"10",      

    with uop_data_size_mux_sel select
       uop_data_size <=
       uop_data_size_reg                                       when "00",
       qa_sig(TIMEOUT_SYNC_END-1 downto DATA_SIZE_END)         when "10",  -- qa_sig(TIMEOUT_SYNC_END-1 downto DATA_SIZE_END)
       (others=>'0')                                           when others;


    with uop_data_count_mux_sel select
       uop_data_count <=
       uop_data_count_reg                                      when "00",
       uop_data_count_reg + 1                                  when "01",
       (others=>'0')                                           when others;

   
    with send_ptr_mux_sel select
       send_ptr <=
       send_ptr_reg                                                when "00",
       send_ptr_reg + 1                                         when "01",
       send_ptr_reg + BB_PACKET_HEADER_SIZE + qa_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END) when "10",
       ADDR_ZERO                                                when others; --"11",



   with crc_num_bits_mux_sel select
      crc_num_bits <=
      crc_num_bits_reg                                          when "00",
      ((BB_PACKET_HEADER_SIZE + uop_data_size_int)*QUEUE_WIDTH) when "01",
      0                                                         when others;
      
   with cmd_tx_dat_mux_sel select
      cmd_tx_dat <=
      cmd_tx_dat_reg                                            when "000",
      BB_PREAMBLE & qa_sig(TIMEOUT_SYNC_END-1 downto 0)         when "001",
      qa_sig(QUEUE_WIDTH-1 downto 0)                            when "010",
      crc_reg                                                   when "011",
      (others=>'0')                                             when others; --"100",
      
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         crc_num_bits_reg  <= 0;
         cmd_tx_dat_reg    <= (others=>'0');
         send_ptr_reg      <= (others=>'0');
         uop_data_count_reg<= (others=>'0');
         uop_data_size_reg <= (others=>'0');
      elsif clk_i'event and clk_i = '1' then
         crc_num_bits_reg  <= crc_num_bits;
         cmd_tx_dat_reg    <= cmd_tx_dat; 
         send_ptr_reg      <= send_ptr;
         uop_data_count_reg<= uop_data_count;
         uop_data_size_reg <= uop_data_size;
      end if;
   end process;

   n_clk             <= not clk_i;
   sync_count_slv    <= sync_num_i;
   -- This line was used when the sync number was generate internally to this block.
   -- Now it is generated externally, but I've kept this line to demonstrate the proper method for converting int=>std_logic_vector
   --sync_count_slv    <= std_logic_vector(conv_unsigned(sync_count_int, 8));
   
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

--x Test packets with multiple data words.  I'm not sure that the insert FSM will work properly with only one state.

--x Find some way to initialize the RAM to 0xFFFFFFFF
-- Don't worry about this

--x There's a problem with the use of the counters i've used in frame_timing and cmd_queue.  
-- They all continue on counting after they've gone past the limit that they count to.
-- The bad thing about this is that if the counter wraps after exceeding the time limit, then there could be problems.
-- The cmd_queue counter has been fixed, but I don't think that the frame_timing counter has.
-- Actually, for the frame_timing block, we do not want the clk_count to restart

--x Check out clk_error, and figure out why it is so out of whack.  
-- It might be something to do with having a faulty period for the sync pulse in the TB.

--x Check out the ***'ed lines

--x uop_counter may not belong on the sensitivity list for insert FSM
-- Removed

--x If the sync pulse changes while I'm transmitting a series of commands that were only good for the previous sync period, what should I do?
-- Stop tranmission?

-- Think about using the free_ptr index to tag the u-op sequence number in the queue.

-- The send FSM needs a way of notifying the retire fsm wheter a u-op has been skipped or not
-- NEXT_UOP in send_states should tag the uop with a special code so that the retire fsm can recognize that it was skipped.
-- I need to insert a code either in the start sync, end sync or data size field.  
-- At this point, I think that I'll use the data size field, because there are definate limits to the size that a packet will be.
-- I can't add a new state in the send state machine that would alter the data field, because you can only read from the qa_sig data port.

-- The calculated CRC is always the same..