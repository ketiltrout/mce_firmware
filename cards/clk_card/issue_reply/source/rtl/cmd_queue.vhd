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
-- $Id: cmd_queue.vhd,v 1.12 2004/06/04 01:22:58 bburger Exp $
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
-- Revision 1.12  2004/06/04 01:22:58  bburger
-- bug fixes
--
-- Revision 1.11  2004/05/27 00:09:45  bburger
-- in progress
--
-- Revision 1.10  2004/05/26 18:04:47  bburger
-- in progress
--
-- Revision 1.9  2004/05/25 21:25:08  bburger
-- in progress
--
-- Revision 1.8  2004/05/21 01:21:56  bburger
-- in progress
--
-- Revision 1.7  2004/05/20 01:59:24  bburger
-- in progress
--
-- Revision 1.6  2004/05/18 18:41:17  bburger
-- in progress
--
-- Revision 1.5  2004/05/17 22:27:27  bburger
-- in progress
--
-- Revision 1.4  2004/05/14 21:40:52  bburger
-- in progress
--
-- Revision 1.3  2004/05/13 00:08:30  bburger
-- in progress
--
-- Revision 1.2  2004/05/12 18:17:53  bburger
-- in progress
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

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;
use work.cmd_queue_ram40_pack.all;

entity cmd_queue is
port (
   -- reply_queue interface
   --mop_retire_o : out std_logic_vector(MOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next m-op that the cmd_queue wants to retire
   --uop_retire_o : out std_logic_vector(UOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next u-op that the cmd_queue wants to retire
   uop_status_i  : in std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
   uop_rdy_o     : out std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   uop_ack_i     : in std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
   uop_discard_o : out std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.
   uop_timedout_o: out std_logic; -- Tells that reply_queue that it should generated a timed-out reply based on the the par_id, card_addr, etc of the u-op being retired.
   uop_o         : out std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

   -- cmd_translator interface
   card_addr_i   : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- The card address of the m-op
   par_id_i      : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- The parameter id of the m-op
   cmd_size_i    : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
   data_i        : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- Data belonging to a m-op
   data_clk_i    : in std_logic; -- Clocks in 32-bit wide data
   mop_i         : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- M-op sequence number
   issue_sync_i  : in std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0); -- The issuing sync-pulse sequence number
   mop_rdy_i     : in std_logic; -- Tells cmd_queue when a m-op is ready
   mop_ack_o     : out std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op

   -- bb_tx interface
   clk_o         : out std_logic;
   -- rst_o is not the responsibility of the cmd_queue
   --rst_o         : out std_logic;
   dat_o         : out std_logic_vector (7 downto 0);
   we_o          : out std_logic;
   stb_o         : out std_logic;
   cyc_o         : out std_logic;
   ack_i         : in std_logic;

   -- Clock lines
   sync_i        : in std_logic; -- The sync pulse determines when and when not to issue u-ops
   clk_i         : in std_logic; -- Advances the state machines
   fast_clk_i    : in std_logic; -- Fast clock used for doing multi-cycle operations (inserting and deleting u-ops from the command queue) in a single clk_i cycle.  fast_clk_i must be at least 2x as fast as clk_i
   rst_i         : in std_logic  -- Resets all FSMs
   );
end cmd_queue;

architecture behav of cmd_queue is

constant H0X00 : std_logic_vector(7 downto 0) := "00000000";
constant H0XFF : std_logic_vector(7 downto 0) := "11111111";

constant ISSUE_SYNC_BUS_WIDTH : integer := 8;  -- The width of the data field for the absolute sync count at which an instruction was issued
constant TIMEOUT_SYNC_BUS_WIDTH : integer := 8;  -- The width of the data field for the absolute sync count at which an instruction expires
constant TIMEOUT_LEN : std_logic_vector(7 downto 0) := "00000001";  -- The number of sync pulses after which an instruction will expire
constant MAX_SYNC_COUNT : integer := 255;

-- Calculated constants for inputing data on the correct lines into/outof the queue
constant MOP_END          : integer := QUEUE_WIDTH - MOP_BUS_WIDTH;
constant UOP_END          : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH;
constant ISSUE_SYNC_END   : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH;
constant TIMEOUT_SYNC_END : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH - TIMEOUT_SYNC_BUS_WIDTH;
constant CARD_ADDR_END    : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH - TIMEOUT_SYNC_BUS_WIDTH - CARD_ADDR_BUS_WIDTH;

-- Command queue inputs/ouputs (this interface was generated by a Quartus II megafunction for a RAM block)
signal data_sig        : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal wraddress_sig   : std_logic_vector(7 downto 0);
signal rdaddress_a_sig : std_logic_vector(7 downto 0);
signal rdaddress_b_sig : std_logic_vector(7 downto 0);
signal wren_sig        : std_logic;
--signal fast_clk        : std_logic;
signal qa_sig          : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal qb_sig          : std_logic_vector(QUEUE_WIDTH-1 downto 0);

-- Output that indicates the number u-ops contained in the command queue
signal uop_counter : std_logic_vector(UOP_BUS_WIDTH - 1 downto 0);

-- Signals from/to the Sync-pulse counter.  This is used to determine when u-ops have expired.
signal sync_count_slv : std_logic_vector(7 downto 0);
signal sync_count_int : integer;
signal frame_rst : std_logic := '0'; -- This zero is a hack.  This should be removed when the FSM is written, and sets frame_rst appropriately
signal clk_count : integer;
signal clk_error : std_logic_vector(31 downto 0);

-- Command queue management variables
signal uops_generated : integer;
signal cards_addressed : integer;
signal num_uops : integer;
signal queue_space : integer := QUEUE_LEN;

-- Command queue address pointers.  Each one of these are managed by a different FSM.
signal retire_ptr : std_logic_vector(7 downto 0) := "00000000";
signal flush_ptr : std_logic_vector(7 downto 0) := "00000000";
signal send_ptr : std_logic_vector(7 downto 0) := "00000000";
signal free_ptr : std_logic_vector(7 downto 0) := "00000000";

-- Insertion FSM:  inserts u-ops into the command queue
type insert_states is (IDLE, INSERT, DONE, RESET, STALL);
signal present_insert_state : insert_states;
signal next_insert_state : insert_states;
signal inserted: std_logic; --Out, to the u-op counter fsm

-- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
type retire_states is (IDLE, NEXT_UOP, STATUS, RETIRE, FLUSH, EJECT, NEXT_FLUSH, FLUSH_STATUS, RESET);
signal present_retire_state : retire_states;
signal next_retire_state    : retire_states;
signal retired : std_logic; --Out, to the u-op counter fsm
signal uop_timed_out : std_logic;

-- Generate FSM:  translates M-ops into u-ops
type gen_uop_states is (IDLE, PARSE, INSERT, RET_DAT, PSC_STATUS, BIT_STATUS, FPGA_TEMP, CARD_TEMP, CYC_OO_SYC, SINGLE, CLEANUP, RESET);
signal present_gen_state : gen_uop_states;
signal next_gen_state    : gen_uop_states;
signal mop_rdy : std_logic; --In from the previous block in the chain
signal insert_uop_rdy : std_logic; --Out, to insertion fsm
signal new_card_addr : std_logic_vector(CARD_ADDR_BUS_WIDTH-1 downto 0); --out, to insertion fsm
signal new_par_id : std_logic_vector(PAR_ID_BUS_WIDTH-1 downto 0) := x"000000"; --out, to insertion fsm.  This is a hack.
signal last_card_uop : std_logic;

-- Send FSM:  sends u-ops over the bus backplane
type send_states is (IDLE, LOAD, VERIFY, ISSUE, WAIT_FOR_ACK, SKIP, RESET);
signal present_send_state : send_states;
signal next_send_state    : send_states;
signal tx_uop_rdy : std_logic;  --Out, to bus backplane packetization fsm
--signal uop_pending : std_logic;  --In ???
--signal uop_expired : std_logic;  --In ???
signal freeze_send : std_logic;  --In, freezes the send pointer when flushing out invalidated u-ops
signal uop_send_expired : std_logic;

-- Bus Backplane Packetization FSM:  packetizes u-ops contained in the command queue into Bus Backplane instruction format
type packet_states is (IDLE, STRT_CMD1, STRT_CMD2, SZ_CMD1, SZ_CMD2, CARD_ADDR, PAR_ID, DATA, CHECKSUM1, CHECKSUM2, DONE);
signal present_packet_state : packet_states;
signal next_packet_state : packet_states;
signal tx_uop_ack : std_logic := '1';  --in, from send fsm.

-- Constants that can be removed when the sync_counter and frame_timer are moved out of this block
constant HIGH : std_logic := '1';
constant LOW : std_logic := '0';
constant INT_ZERO : integer := 0;

begin
   -- Command queue (FIFO)
   cmd_queue_ram40_inst: cmd_queue_ram40
      port map(
         data        => data_sig,
         wraddress   => wraddress_sig,
         rdaddress_a => rdaddress_a_sig,
         rdaddress_b => rdaddress_b_sig,
         wren        => wren_sig,
         clock       => fast_clk_i,
         qa          => qa_sig,
         qb          => qb_sig
      );

   -- The sync counter will be moved outside this block
   sync_counter: counter
      generic map(MAX => MAX_SYNC_COUNT)
      port map(
         clk_i   => sync_i,
         rst_i   => rst_i,
         ena_i   => HIGH,
         load_i  => LOW,
         down_i  => LOW,
         count_i => INT_ZERO,
         count_o => sync_count_int
      );

   frame_timer: frame_timing
     port map(
         clk_i => clk_i,
         sync_i => sync_i,
         frame_rst_i => frame_rst,
         clk_count_o => clk_count,
         clk_error_o => clk_error
     );

   -- Counter for tracking free space in the queue:
   space_calc: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         queue_space <= QUEUE_LEN;
      elsif(clk_i'event and clk_i = '1') then
         if(inserted = '1' and retired = '0') then
            queue_space <= queue_space - 1;
         elsif(inserted = '0' and retired = '1') then
            queue_space <= queue_space + 1;
         -- All other operations balance each other out
         end if;
      end if;
   end process;

   -- FSM for inserting u-ops into the u-op queue
   -- Assumes that fast_clk_i is in phase with clk_i
   insert_state_FF: process(fast_clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_insert_state <= RESET;
      elsif(fast_clk_i'event and fast_clk_i = '1') then
         present_insert_state <= next_insert_state;
      end if;
   end process;

   insert_state_NS: process(present_insert_state, insert_uop_rdy, clk_i)
   begin
      case present_insert_state is
         when RESET =>
            next_insert_state <= IDLE;
         when IDLE =>
            -- The gen_state FSM will only try to add a u-op to the queue if there is space available, so no checking is necessary here.  i.e. no ack signal is required
            -- ***This needs to react as soon as there is a u-op ready to insert..
            if(insert_uop_rdy = '1') then
               next_insert_state <= INSERT;
            else
               next_insert_state <= IDLE;
            end if;
         when INSERT =>
            next_insert_state <= DONE;
         when DONE =>
            next_insert_state <= STALL;
         when STALL =>
            if(clk_i'event and clk_i = '1') then
               next_insert_state <= IDLE;
            else
               next_insert_state <= STALL;
            end if;
         when others =>
            next_insert_state <= IDLE;
      end case;
   end process;

   insert_state_out: process(present_insert_state, mop_i, uop_counter, issue_sync_i, new_card_addr, new_par_id)
   -- There is something sketchy about the sensitivity list.  free_ptr does not appear anywhere on the list.  It can't because of my free_ptr <= free_ptr + 1 statement below.  However, it should because it appears on the lhs in the INSERT state
   begin
      case present_insert_state is
         when RESET =>
            free_ptr <= H0X00;
            wren_sig <= '0';
         when IDLE =>
            wren_sig <= '0';
            -- The RAM block and the functions that write to it will be operating at higher speed than the rest of the logic.  INSERT and DONE should complete in less than one clk_i cycle
         when INSERT =>
            data_sig(QUEUE_WIDTH - 1 downto MOP_END)             <= mop_i;
            data_sig(MOP_END - 1 downto UOP_END)                 <= uop_counter; -- new u-op sequence number.  This FSM automatically increments uop_counter after a u-op is added.
            data_sig(UOP_END - 1 downto ISSUE_SYNC_END)          <= issue_sync_i;
            data_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) <= issue_sync_i + TIMEOUT_LEN;
            data_sig(TIMEOUT_SYNC_END - 1 downto CARD_ADDR_END)  <= new_card_addr;
            data_sig(CARD_ADDR_END - 1 downto 0)                 <= new_par_id(7 downto 0);
            wraddress_sig                                        <= free_ptr;
            wren_sig                                             <= '1';
         when DONE =>
            -- After adding a new u-op:
            if(free_ptr = H0XFF) then
               free_ptr <= H0X00;
            else
               free_ptr <= free_ptr + 1;
            end if;
            wren_sig <= '0';
         when STALL =>
            wren_sig <= '0';
         when others =>
            wren_sig <= '0';
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
--         when FLUSH_DONE =>
--            next_retire_state <= IDLE;
         when others =>
            next_retire_state <= IDLE;
      end case;
   end process;

   rdaddress_b_sig <= retire_ptr;
   uop_o <= qb_sig;

   retire_state_out: process(present_retire_state)
   begin
      case present_retire_state is
         when RESET =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
            uop_timedout_o <= '0';
            uop_discard_o  <= '0';
            retire_ptr     <= H0X00;
            flush_ptr      <= H0X00;
            retired        <= '0';
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
            if(retire_ptr >= QUEUE_LEN - 1) then
               retire_ptr  <= H0X00;
            else
               retire_ptr  <= retire_ptr + 1;
            end if;
            if(flush_ptr >= QUEUE_LEN - 1) then
               flush_ptr  <= H0X00;
            else
               flush_ptr  <= flush_ptr + 1;
            end if;
         when FLUSH =>
            uop_rdy_o      <= '0';
            freeze_send    <= '1';
            uop_timedout_o <= '0';
            uop_discard_o  <= '1';
            retired        <= '1';
         when EJECT =>
            uop_rdy_o      <= '0';
            freeze_send    <= '0';
            uop_timedout_o <= '1';
            uop_discard_o  <= '1';
            retired        <= '1';
            if(retire_ptr >= QUEUE_LEN - 1) then
               retire_ptr  <= H0X00;
            else
               retire_ptr  <= retire_ptr + 1;
            end if;
            if(flush_ptr >= QUEUE_LEN - 1) then
               flush_ptr  <= H0X00;
            else
               flush_ptr  <= flush_ptr + 1;
            end if;
         when NEXT_FLUSH =>
            uop_rdy_o      <= '1';
            freeze_send    <= '1';
            uop_timedout_o <= '0';
            uop_discard_o  <= '1';
            retired        <= '0';
            if(flush_ptr >= QUEUE_LEN - 1) then
               flush_ptr   <= H0X00;
            else
               flush_ptr   <= flush_ptr + 1;
            end if;
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

   last_card_uop <= '1' when ((card_addr_i = BCS and new_card_addr = BC3) or (card_addr_i = RCS and new_card_addr = RC4) or
                              (card_addr_i = ALL_FBGA_CARDS and new_card_addr = AC) or (card_addr_i = ALL_CARDS and new_card_addr = AC)) else '0';

   gen_state_NS: process(present_gen_state, mop_rdy, queue_space, num_uops, par_id_i, card_addr_i, new_card_addr, last_card_uop)
   begin
      case present_gen_state is
         when RESET =>
            next_gen_state <= IDLE;
         when IDLE =>
            if(mop_rdy = '0') then
               next_gen_state <= IDLE;
            elsif(mop_rdy = '1') then
               next_gen_state <= PARSE;
            end if;
         when PARSE =>
            if(queue_space < num_uops) then
               next_gen_state <= PARSE;
            elsif(queue_space >= num_uops) then
               next_gen_state <= INSERT;
            end if;
         when INSERT =>
            if(par_id_i(7 downto 0) = RET_DAT_ADDR) then
               next_gen_state <= RET_DAT;
            elsif(par_id_i(7 downto 0) = STATUS_ADDR) then
               next_gen_state <= PSC_STATUS;
            else
               next_gen_state <= SINGLE;
            end if;
         when RET_DAT | PSC_STATUS | BIT_STATUS | FPGA_TEMP | CARD_TEMP | CYC_OO_SYC =>
            case card_addr_i is
               when NO_CARDS =>
                  next_gen_state <= CLEANUP;
               -- Single card, multiple u-ops
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC =>
                  if(present_gen_state = RET_DAT) then
                     next_gen_state <= PSC_STATUS;
                  elsif(present_gen_state = PSC_STATUS) then
                     next_gen_state <= BIT_STATUS;
                  elsif(present_gen_state = BIT_STATUS) then
                     next_gen_state <= FPGA_TEMP;
                  elsif(present_gen_state = FPGA_TEMP) then
                     next_gen_state <= CARD_TEMP;
                  elsif(present_gen_state = CARD_TEMP) then
                     next_gen_state <= CYC_OO_SYC;
                  elsif(present_gen_state = CYC_OO_SYC) then
                     next_gen_state <= CLEANUP;
                  end if;



               when BCS | RCS | ALL_FBGA_CARDS | ALL_CARDS =>
                  -- Determine the next in the sequence of u-ops to be issued to a specific card
                  if(present_gen_state = RET_DAT and last_card_uop = '1') then
                     next_gen_state <= PSC_STATUS;
                  elsif(present_gen_state = PSC_STATUS and last_card_uop = '1') then
                     next_gen_state <= BIT_STATUS;
                  elsif(present_gen_state = BIT_STATUS and last_card_uop = '1') then
                     next_gen_state <= FPGA_TEMP;
                  elsif(present_gen_state = FPGA_TEMP and last_card_uop = '1') then
                     next_gen_state <= CARD_TEMP;
                  elsif(present_gen_state = CARD_TEMP and last_card_uop = '1') then
                     next_gen_state <= CYC_OO_SYC;
                  elsif(present_gen_state = CYC_OO_SYC and last_card_uop = '1') then
                     -- CYC_OO_SYNC is the last u-op to be issued for m-op that are broken down into several u-ops
                     --if(last_card_uop = '1') then
                        next_gen_state <= CLEANUP;
                     -- Here, we either start issuing the same sequence of u-ops to the next card in the list, or we've finished the list.
                     --elsif(par_id_i(7 downto 0) = RET_DAT_ADDR) then
                     --   next_gen_state <= RET_DAT;
                     --elsif(par_id_i(7 downto 0) = STATUS_ADDR) then
                     --   next_gen_state <= PSC_STATUS;
                     --else
                     --   next_gen_state <= CLEANUP;
                     --end if;
                  end if;
               when others => next_gen_state <= CLEANUP;






            end case;
         when SINGLE =>
            -- Single card, single u-op
            next_gen_state <= CLEANUP;
         when CLEANUP => next_gen_state <= IDLE;
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
         9 when ALL_FBGA_CARDS,
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

   num_uops <= uops_generated * cards_addressed;
   mop_rdy <= mop_rdy_i;

   gen_state_out: process(present_gen_state, card_addr_i, clk_i) -- had new_card_addr_i
      begin
      -- Note that inserted and insert_uop_rdy follow each other exactly
      case present_gen_state is
         when RESET =>
            mop_ack_o      <= '0';
            insert_uop_rdy <= '0';
            inserted       <= '0';
            new_card_addr  <= card_addr_i;
         when IDLE =>
            mop_ack_o      <= '0';
            insert_uop_rdy <= '0';
            inserted       <= '0';
            new_card_addr  <= card_addr_i;
         when PARSE =>
            mop_ack_o      <= '0';
            insert_uop_rdy <= '0';
            inserted       <= '0';
            new_card_addr  <= card_addr_i;
         when INSERT =>
            -- Add new u-ops to the queue
            mop_ack_o      <= '0';
            insert_uop_rdy <= '0';
            inserted       <= '0';
            uop_counter    <= (others => '0');
            new_card_addr  <= card_addr_i;
--            if(card_addr_i = BCS) then
--               new_card_addr <= BC1;
--            elsif(card_addr_i = RCS) then
--               new_card_addr <= RC1;
--            elsif(card_addr_i = ALL_FBGA_CARDS) then
--               new_card_addr <= CC;
--            elsif(card_addr_i = ALL_CARDS) then
--               new_card_addr <= PSC;
--            end if;
         when RET_DAT | PSC_STATUS | BIT_STATUS | FPGA_TEMP | CARD_TEMP | CYC_OO_SYC =>
            if   (present_gen_state = RET_DAT)    then new_par_id(7 downto 0) <= RET_DAT_ADDR;
            elsif(present_gen_state = PSC_STATUS) then new_par_id(7 downto 0) <= PSC_STATUS_ADDR;
            elsif(present_gen_state = BIT_STATUS) then new_par_id(7 downto 0) <= BIT_STATUS_ADDR;
            elsif(present_gen_state = FPGA_TEMP)  then new_par_id(7 downto 0) <= FPGA_TEMP_ADDR;
            elsif(present_gen_state = CARD_TEMP)  then new_par_id(7 downto 0) <= CARD_TEMP_ADDR;
            elsif(present_gen_state = CYC_OO_SYC) then new_par_id(7 downto 0) <= CYC_OO_SYC_ADDR;
            end if;
            case card_addr_i is
               -- For any card address that may appear, we set the new_card_addr appropriately
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC | BCS | RCS | ALL_FBGA_CARDS | ALL_CARDS =>
                  uop_counter <= uop_counter + 1;
                  insert_uop_rdy <= '1';
                  inserted       <= '1';
                  if(card_addr_i = BCS and clk_i'event and clk_i = '1') then
                     if(new_card_addr = BCS) then
                        new_card_addr <= BC1;
                     elsif(new_card_addr = BC1) then
                        new_card_addr <= BC2;
                     elsif(new_card_addr = BC2) then
                        new_card_addr <= BC3;
                     elsif(new_card_addr = BC3) then
                        new_card_addr <= BC1;
                     end if;
                  elsif(card_addr_i = RCS and clk_i'event and clk_i = '1') then
                     if(new_card_addr = RCS) then
                        new_card_addr <= RC1;
                     elsif(new_card_addr = RC1) then
                        new_card_addr <= RC2;
                     elsif(new_card_addr = RC2) then
                        new_card_addr <= RC3;
                     elsif(new_card_addr = RC3) then
                        new_card_addr <= RC4;
                     elsif(new_card_addr = RC4) then
                        new_card_addr <= RC1;
                     end if;
                  elsif(card_addr_i = ALL_FBGA_CARDS and clk_i'event and clk_i = '1') then
                     if(new_card_addr = ALL_CARDS) then
                        new_card_addr <= CC;
                     elsif(new_card_addr = CC) then
                        new_card_addr <= RC1;
                     elsif(new_card_addr = RC1) then
                        new_card_addr <= RC2;
                     elsif(new_card_addr = RC2) then
                        new_card_addr <= RC3;
                     elsif(new_card_addr = RC3) then
                        new_card_addr <= RC4;
                     elsif(new_card_addr = RC4) then
                        new_card_addr <= BC1;
                     elsif(new_card_addr = BC1) then
                        new_card_addr <= BC2;
                     elsif(new_card_addr = BC2) then
                        new_card_addr <= BC3;
                     elsif(new_card_addr = BC3) then
                        new_card_addr <= AC;
                     elsif(new_card_addr = AC) then
                        new_card_addr <= CC;
                     end if;
                  elsif(card_addr_i = ALL_CARDS and clk_i'event and clk_i = '1') then
                     if(new_card_addr = ALL_CARDS) then
                        new_card_addr <= PSC;
                     elsif(new_card_addr = PSC) then
                        new_card_addr <= CC;
                     elsif(new_card_addr = CC) then
                        new_card_addr <= RC1;
                     elsif(new_card_addr = RC1) then
                        new_card_addr <= RC2;
                     elsif(new_card_addr = RC2) then
                        new_card_addr <= RC3;
                     elsif(new_card_addr = RC3) then
                        new_card_addr <= RC4;
                     elsif(new_card_addr = RC4) then
                        new_card_addr <= BC1;
                     elsif(new_card_addr = BC1) then
                        new_card_addr <= BC2;
                     elsif(new_card_addr = BC2) then
                        new_card_addr <= BC3;
                     elsif(new_card_addr = BC3) then
                        new_card_addr <= AC;
                     elsif(new_card_addr = AC) then
                        new_card_addr <= PSC;
                     end if;
                  end if;
               when others => -- Invalid card address
                  insert_uop_rdy <= '0';
                  inserted       <= '0';
            end case;
         when SINGLE =>
            uop_counter    <= uop_counter + 1;
            mop_ack_o      <= '0';
            insert_uop_rdy <= '1';
            inserted       <= '1';
            new_card_addr  <= card_addr_i;
         when CLEANUP =>
            mop_ack_o      <= '1';
            insert_uop_rdy <= '0';
            inserted       <= '0';
            new_card_addr  <= card_addr_i;
         when others => -- Normal insertion
            mop_ack_o      <= '0';
            insert_uop_rdy <= '0';
            inserted       <= '0';
            new_card_addr  <= card_addr_i;
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

   send_state_NS: process(present_send_state, send_ptr, free_ptr, qa_sig, clk_count, uop_send_expired, issue_sync_i, tx_uop_ack)
   begin
      case present_send_state is
         when RESET =>
            next_send_state <= IDLE;
         when IDLE =>
            -- If there is a u-op waiting to be issued, load it.  If not, idle
            if(send_ptr /= free_ptr) then
               next_send_state <= LOAD;
            elsif(send_ptr = free_ptr) then
               next_send_state <= IDLE;
            end if;
         when LOAD =>
            -- Assert the data address, and retrieve the next u-op
            next_send_state <= VERIFY;
         when VERIFY =>
            if(uop_send_expired = '1') then
               -- If the u-op has expired, it should be skipped
               next_send_state <= SKIP;
            elsif(qa_sig(UOP_END-1 downto ISSUE_SYNC_END) = issue_sync_i and clk_count > START_OF_BLACKOUT) then
               -- The black out period has started - even though the command was for this sync period, it has expired.
               next_send_state <= SKIP;
            elsif(qa_sig(UOP_END-1 downto ISSUE_SYNC_END) = issue_sync_i and clk_count < START_OF_BLACKOUT) then
               -- If the u-op can be issued during this sync period, and if the remaining cycle time is sufficient to send the instruction, issue.
               next_send_state <= ISSUE;
            else
               -- If the u-op is still good, but isn't supposed to be issued yet, stay in VERIFY
               next_send_state <= VERIFY;
            end if;
         when ISSUE =>
            next_send_state <= WAIT_FOR_ACK;
            -- Clock the instruction out over the LVDS lines.
         when WAIT_FOR_ACK =>
            if(tx_uop_ack = '1') then
               next_send_state <= SKIP;
            elsif(tx_uop_ack = '0') then
               next_send_state <= WAIT_FOR_ACK;
            end if;
         when SKIP =>
            -- Skip to the next u-op
            next_send_state <= IDLE;
         when others =>
            next_send_state <= IDLE;
      end case;
   end process;

   uop_send_expired <= '1' when (sync_count_slv > qa_sig(UOP_END - 1 downto ISSUE_SYNC_END) or
                                (sync_count_slv < qa_sig(UOP_END - 1 downto ISSUE_SYNC_END) and
                                 MAX_SYNC_COUNT - qa_sig(UOP_END - 1 downto ISSUE_SYNC_END) + sync_count_slv > TIMEOUT_LEN)) else '0';
   rdaddress_a_sig <= send_ptr;

   send_state_out: process(present_send_state, send_ptr)
   begin
      case present_send_state is
         when RESET =>
            send_ptr <= H0X00;
         when IDLE =>
            tx_uop_rdy <= '0';
         when LOAD =>
            tx_uop_rdy <= '0';
         when VERIFY =>
            tx_uop_rdy <= '0';
         when ISSUE =>
            -- All issue functionality may be contained in the Bus Backplane Packetization FSM
            tx_uop_rdy <= '1';
         when WAIT_FOR_ACK =>
            tx_uop_rdy <= '0';
         when SKIP =>
            tx_uop_rdy <= '0';
            if(send_ptr >= QUEUE_LEN-1) then
               send_ptr <= H0X00;
            else
               send_ptr <= send_ptr + 1;
            end if;
         when others =>
            tx_uop_rdy <= '0';
      end case;
   end process;

   -- Packetization FSM
   packet_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_packet_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_packet_state <= next_packet_state;
      end if;
   end process;

--   packet_state_NS: process()
--   begin
--      case present_packet_state is
--         when IDLE =>
--         when STRT_CMD1 =>
--         when STRT_CMD2 =>
--         when SZ_CMD1 =>
--         when SZ_CMD2 =>
--         when CARD_ADDR =>
--         when PAR_ID =>
--         when DATA =>
--         when CHECKSUM1 =>
--         when CHECKSUM2 =>
--         when DONE =>
--         when others
--      end case;
--   end process;
--
--   packet_state_out: process()
--   begin
--      case present_packet_state is
--         when IDLE =>
--         when STRT_CMD1 =>
--         when STRT_CMD2 =>
--         when SZ_CMD1 =>
--         when SZ_CMD2 =>
--         when CARD_ADDR =>
--         when PAR_ID =>
--         when DATA =>
--         when CHECKSUM1 =>
--         when CHECKSUM2 =>
--         when DONE =>
--         when others
--      end case;
--   end process;

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

   --x new_card_addr should change one clock cycle earlier at the beginning of a sequence of u-ops issued

   --x the generate FSM cycles over two u-op during a u-op transition


   sync_count_slv <= conv_std_logic_vector(sync_count_int, 8);
   clk_o <= clk_i;

end behav;