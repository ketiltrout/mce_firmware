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
-- $Id: cmd_queue.vhd,v 1.6 2004/05/18 18:41:17 bburger Exp $
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

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.frame_timing_pack.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;

--make a pack file for this and declare it as a component
use work.cmd_queue_ram40.all;

entity cmd_queue is
port (
   -- reply_queue interface
   mop_retire_o : out std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next m-op that the cmd_queue wants to retire
   uop_retire_o : out std_logic_vector (UOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next u-op that the cmd_queue wants to retire
   uop_status_i : in std_logic_vector (UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
   uop_rdy_o    : in std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   uop_ack_i    : out std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
   uop_discard_o: out std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.

   -- cmd_translator interface
   card_addr_i  : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- The card address of the m-op
   par_id_i     : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- The parameter id of the m-op
   cmd_size_i   : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
   data_i       : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- Data belonging to a m-op
   mop_i        : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- M-op sequence number
   issue_sync_i : in std_logic; -- Bit will be toggled with each new m-op that belongs to a different sync period
   mop_rdy_i    : in std_logic; -- Tells cmd_queue when a m-op is ready
   mop_ack_o    : out std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op

   -- bb_tx interface
   clk_o        : out std_logic;
   rst_o        : out std_logic;
   dat_o        : out std_logic_vector (7 downto 0);
   we_o         : out std_logic;
   stb_o        : out std_logic;
   cyc_o        : out std_logic;
   ack_i        : in std_logic;
   --addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0);
   --tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
   --dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
   --rty_o   : out std_logic;

   -- Clock lines
   sync_i       : in std_logic; -- The sync pulse determines when and when not to issue u-ops
   clk_i        : in std_logic; -- Advances the state machines
   fast_clk_i   : in std_logic  -- Fast clock used for doing multi-cycle operations (inserting and deleting u-ops from the command queue) in a single clk_i cycle.  fast_clk_i must be at least 2x as fast as clk_i
   );
end cmd_queue;

architecture behav of cmd_queue is

constant HIGH : std_logic := '1';
constant LOW : std_logic := '0';
constant H0X00 : std_logic_vector(7 downto 0) := "00000000";
constant H0XFF : std_logic_vector(7 downto 0) := "11111111";

constant QUEUE_LEN   : integer  := 256; -- The u-op queue is 256 entries long
constant QUEUE_WIDTH : integer  := 40; -- The u-op queue is 40 bits wide
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
signal clock_sig       : std_logic;
signal qa_sig          : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal qb_sig          : std_logic_vector(QUEUE_WIDTH-1 downto 0);

-- Output that indicates the number u-ops contained in the command queue
variable uop_counter : std_logic_vector(UOP_BUS_WIDTH downto 0);

-- Signals from/to the Sync-pulse counter.  This is used to determine when u-ops have expired.
signal sync_count_sig : std_logic_vector(7 downto 0);
signal sync_tog : std_logic;
signal frame_rst : std_logic;
signal clk_count : integer;
signal clk_error : std_logic_vector(31 downto 0);

-- Command queue management variables
variable uops_generated : integer;
variable cards_addressed : integer;
variable num_uops : integer;
variable queue_space : integer := QUEUE_LEN;

-- Command queue address pointers.  Each one of these are managed by a different FSM.
variable retire_ptr : std_logic_vector(7 downto 0) := "00000000";
variable flush_ptr : std_logic_vector(7 downto 0) := "00000000";
variable send_ptr : std_logic_vector(7 downto 0) := "00000000";
variable free_ptr : std_logic_vector(7 downto 0) := "00000000";

-- Insertion FSM:  inserts u-ops into the command queue
type insert_states is (IDLE, INSERT, DONE);
signal present_insert_state : insert_states;
signal next_insert_state : insert_states;
signal inserted: std_logic; --Out, to the u-op counter fsm

-- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
type retire_states is (IDLE, NEXT_UOP, STATUS, RETIRE, FLUSH, NEXT_FLUSH, FLUSH_STATUS, FLUSH_DONE);
signal present_retire_state : retire_states;
signal next_retire_state    : retire_states;
signal retired : std_logic; --Out, to the u-op counter fsm

-- Generate FSM:  translates M-ops into u-ops
type gen_uop_states is (IDLE, PARSE, INSERT, RET_DAT, PSC_STATUS, BIT_STATUS, FPGA_TEMP, CARD_TEMP, CYC_OO_SYC, SINGLE, CLEANUP);
signal present_gen_state : gen_uop_states;
signal next_gen_state    : gen_uop_states;
signal mop_rdy : std_logic; --In from the previous block in the chain
signal insert_uop_rdy : std_logic; --Out, to insertion fsm
signal new_card_addr : std_logic_vector(CARD_ADDR_BUS_WIDTH-1 downto 0); --out, to insertion fsm
signal new_par_id : std_logic_vector(PAR_ID_BUS_WIDTH-1 downto 0); --out, to insertion fsm

-- Send FSM:  sends u-ops over the bus backplane
type send_states is (IDLE, LOAD, VERIFY, ISSUE, WAIT_FOR_ACK, SKIP);
signal present_send_state : send_states;
signal next_send_state    : send_states;
signal tx_uop_rdy : std_logic;  --Out, to bus backplane packetization fsm
signal uop_pending : std_logic;  --In
signal uop_expired : std_logic;  --In
signal freeze_send : std_logic;  --In, freezes the send pointer when flushing out invalidated u-ops

-- Bus Backplane Packetization FSM:  packetizes u-ops contained in the command queue into Bus Backplane instruction format
type packet_state is (IDLE, STRT_CMD1, STRT_CMD2, SZ_CMD1, SZ_CMD2, CARD_ADDR, PAR_ID, DATA, CHECKSUM1, CHECKSUM2, DONE);
signal present_packet_state : packet_states;
signal next_packet_state : packet_states;
signal tx_uop_ack : std_logic;  --Out, to send fsm


begin
   -- Command queue (FIFO)
   cmd_queue_ram40_inst : cmd_queue_ram40
      port map(
         data        => data_sig,
         wraddress   => wraddress_sig,
         rdaddress_a => rdaddress_a_sig,
         rdaddress_b => rdaddress_b_sig,
         wren        => wren_sig,
         clock       => clock_sig,
         qa          => qa_sig,
         qb          => qb_sig
      );

   sync_counter : counter
      generic map(MAX => MAX_SYNC_COUNT)
      port map(
         clk_i   => sync_i,
         rst_i   => LOW,
         ena_i   => HIGH,
         load_i  => LOW,
         down_i  => LOW,
         count_i => H0X00,
         count_o => sync_count_sig
      );

   frame_timer : frame_timing
     port map(
         clk_i => clk_i,
         sync_i => sync_i,
         frame_rst_i => frame_rst,
         clk_count_o => clk_count,
         clk_error_o => clk_error
     );

   -- Counter for tracking free space in the queue:
   queue_space : process(fast_clock, rst_i)
   begin
      if(rst_i = '1') then
         queue_space <= QUEUE_LEN;
      elsif(clk_i'event and clk_i = '1')
         if(inserted = '1' and retired = '0')
            queue_space = queue_space - 1;
         elsif(inserted = '0' and retired = '1')
            queue_space = queue_space + 1;
         end if;
      end if;
   end process queue_space;

   -- FSM for tracking sync periods
   sync_peroid: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         sync_tog <= '0';
      elsif(clk_i'event and clk_i = '1' and clk_count = 0) then
         if(sync_tog = '0')
            sync_tog <= '1';
         else
            sync_tog <= '0';
         end if;
      end if;
   end process sync_state_FF;

   -- FSM for inserting u-ops into the u-op queue
   insert_state_FF: process(clk_i, fast_clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_insert_state <= IDLE;
      elsif(fast_clk_i'event and fast_clk_i = '1') then
         present_insert_state <= next_insert_state;
      end if;
   end process insert_state_FF;

   insert_state_NS: process(present_insert_state, insert_uop_rdy, clk_i)
   begin
      case present_insert_state is
         when IDLE =>
            -- The gen_state FSM will only try to add a u-op to the queue if there is space available, so no checking is necessary here.  i.e. no ack signal is required
            -- ***This needs to react as soon as there is a u-op ready to insert..
            if(clk_i'event and clk_i = '1' and insert_uop_rdy = '1')
               next_insert_state <= INSERT;
            else
               next_insert_state <= IDLE;
            end if;
         when INSERT =>
            next_insert_state <= DONE;
         when DONE =>
            next_insert_state <= IDLE;
   end process insert_state_NS;

   insert_state_out: process(present_insert_state)
   begin
      case present_insert_state is
         when IDLE;
            -- The RAM block and the functions that write to it will be operating at higher speed than the rest of the logic.  INSERT and DONE should complete in lest than one clk_i cycle
         when INSERT =>
            data_sig(QUEUE_WIDTH - 1 downto MOP_END)             <= mop_i;
            data_sig(MOP_END - 1 downto UOP_END)                 <= uop_counter; -- new u-op sequence number.  This FSM automatically increments uop_counter after a u-op is added.
            data_sig(UOP_END - 1 downto ISSUE_SYNC_END)          <= issue_sync;
            data_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) <= issue_sync + TIMEOUT_LEN;
            data_sig(TIMEOUT_SYNC_END - 1 downto CARD_ADDR_END)  <= new_card_addr;
            data_sig(CARD_ADDR_END - 1 downto 0)                 <= new_par_id;
            wraddress_sig                                        <= free_ptr;
            wren_sig                                             <= '1';
            inserted                                             <= '1';
         when DONE =>
            -- After adding a new u-op:
            if(free_ptr = H0XFF)
               free_ptr <= H0X00;
            else
               free_ptr <= free_ptr + 1;
            end if;
            uop_counter <= uop_counter + 1;
            wren_sig <= '0';
            inserted <= '0';
         when others =>
            wren_sig <= '0';
            inserted <= '0';
   end process insert_state_out;

   -- Retire FSM:
   --   mop_retire_o : out std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next m-op that the cmd_queue wants to retire
   --   uop_retire_o : out std_logic_vector (UOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next u-op that the cmd_queue wants to retire
   --   uop_status_i : in std_logic_vector (UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
   --   uop_rdy_o    : in std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   --   uop_ack_i    : out std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on rq_uop_status_i
   --   uop_discard_o: out std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when rq_rdy_i goes low.  rq_rdy_o can only go low after rq_ack_o has been received.

   retire_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_retire_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_retire_state <= next_retire_state;
      end if;
   end process retire_state_FF;

   retire_state_NS: process(present_retire_state)
   begin
      uop_timed_out    <= '1' when (sync_count_sig > qb(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) or
                                   (sync_count_sig < qb(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) and
                                   (MAX_SYNC_COUNT - qb(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) + sync_count_sig > TIMEOUT_LEN)) else '0';
      case present_retire_state is
         when IDLE =>
            if(retire_ptr != send_ptr)
               next_retire_state <= NEXT_UOP;
            else
               next_retire_state <= IDLE;
            end if;
         when NEXT_UOP =>
            next_retire_state <= STATUS;
         when STATUS =>
            if(uop_ack_i = '1')
               if(uop_status_i = SUCCESS)
                  next_retire_state <= RETIRE;
               elsif(uop_status_i = FAILURE)
                  next_retire_state <= FLUSH;
               end if;
            else if (uop_ack_i = '0')
               next_retire_state <= STATUS;
            end if;
         when RETIRE =>
            next_retire_state <= IDLE;
         when FLUSH =>
            next_retire_state
         when NEXT_FLUSH =>
         when FLUSH_STATUS =>
         when FLUSH_DONE =>
         when others;
      end case;
   end process retire_state_NS;

   retire_state_out: process(present_retire_state)
   begin
      rdaddress_b_sig <= retire_ptr;
      mop_retire_o <= qb_sig(QUEUE_WIDTH-1 downto MOP_END);
      uop_retire_o <= qb_sig(MOP_END-1 downto UOP_END);
      case present_retire_state is
         when IDLE =>
            uop_rdy_o <= '0';
            freeze_send <= '0';
         when NEXT_UOP =>
            uop_rdy_o <= '1';
            freeze_send <= '0';
         when STATUS =>
            uop_rdy_o <= '1';
            freeze_send <= '0';
         when RETIRE =>
            uop_rdy_o <= '0';
            freeze_send <= '0';
         when FLUSH =>
            uop_rdy_o <= '0';
            freeze_send <= '';
         when NEXT_FLUSH =>
            uop_rdy_o <= '1';
            freeze_send <= '';
         when FLUSH_STATUS =>
            uop_rdy_o <= '1';
            freeze_send <= '';
         when FLUSH_DONE =>
            uop_rdy_o <= '0';
            freeze_send <= '';
         when others;
      end case;
   end process retire_state_out;

   -- Generate FSM:
   gen_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_gen_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_gen_state <= next_gen_state;
      end if;
   end process gen_state_FF;

   gen_state_NS: process(present_gen_state, mop_rdy, queue_space, num_uops, par_id_i, card_addr_i)
   begin
      case present_gen_state is
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
            if(par_id_i = RET_DATA_ADDR);
               next_gen_state <= RET_DATA;
            elsif(par_id_i = STATUS_ADDR);
               next_gen_state <= PSC_STATUS;
            else
               next_gen_state <= SINGLE;
            end if;
         when RET_DAT | PSC_STATUS | BIT_STATUS | FPGA_TEMP | CARD_TEMP | CYC_OO_SYC =>
            case card_addr_i is
               when NO_CARDS =>
                  next_gen_state <= CLEANUP;
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC =>
                  if(present_gen_state = RET_DAT)
                     next_gen_state <= PSC_STATUS;
                  elsif(present_gen_state = PSC_STATUS)
                     next_gen_state <= BIT_STATUS;
                  elsif(present_gen_state = BIT_STATUS)
                     next_gen_state <= FPGA_TEMP;
                  elsif(present_gen_state = FPGA_TEMP;
                     next_gen_state <= CARD_TEMP;
                  elsif(present_gen_state = CARD_TEMP;
                     next_gen_state <= CYC_OO_SYC;
                  elsif(present_gen_state = CYC_OO_SYC;
                     next_gen_state <= CLEANUP;
                  end if;
               when BCS | RCS | ALL_FBGA_CARDS | ALL_CARDS =>
                  -- Only switch to the next command state when finished issuing u-ops to all the cards that must receive this command.
                  -- This statement the body of this condition will only execute when instructions for all cards in the card address group have been issued.
                  if((card_addr_i = BCS and new_card_addr = BC3) or
                     (card_addr_i = RCS and new_card_addr = RC4) or
                     (card_addr_i = ALL_FBGA_CARDS and new_card_addr = AC) or
                     (card_addr_i = ALL_CARDS and new_card_addr = AC))
                     if(present_gen_state = RET_DAT)
                        next_gen_state <= PSC_STATUS;
                     elsif(present_gen_state = PSC_STATUS)
                        next_gen_state <= BIT_STATUS;
                     elsif(present_gen_state = BIT_STATUS)
                        next_gen_state <= FPGA_TEMP;
                     elsif(present_gen_state = FPGA_TEMP;
                        next_gen_state <= CARD_TEMP;
                     elsif(present_gen_state = CARD_TEMP;
                        next_gen_state <= CYC_OO_SYC;
                     elsif(present_gen_state = CYC_OO_SYC;
                        next_gen_state <= CLEANUP;
                     end if;
                  end if;
               when others => next_gen_state <= CLEANUP;
            end case;
         when SINGLE =>
            -- Single card, single instruction
            next_gen_state <= CLEANUP;
         when CLEANUP => next_gen_state <= IDLE;
         when others next_gen_state <= IDLE;
      end case;
   end process state_NS;

   gen_state_out: process(present_gen_state, card_addr_i)
      begin

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
      with par_id_i select
         uops_generated <=
            6 when RET_DAT_ADDR,
            5 when STATUS_ADDR,
            1 when others; -- all other m-ops generate one u-op

      num_uops <= uops_generated * cards_addressed;
      mop_rdy <= mop_rdy_i;
      case present_gen_state is
         when IDLE =>
            mop_ack_o <= '0';
            insert_uop_rdy <= '0';
            new_card_addr <= card_addr_i;
         when PARSE =>
            mop_ack_o <= '0';
            insert_uop_rdy <= '0';
            new_card_addr <= card_addr_i;
         when INSERT =>
            -- Add new u-ops to the queue
            mop_ack_o <= '0';
            insert_uop_rdy <= '0';
            uop_counter <= (others => '0');
            new_card_addr <= card_addr_i;
         when RET_DAT | PSC_STATUS | BIT_STATUS | FPGA_TEMP | CARD_TEMP | CYC_OO_SYC =>
            if   (present_gen_state = RET_DATA)   new_par_id <= RET_DAT_ADDR;
            elsif(present_gen_state = PSC_STATUS) new_par_id <= PSC_STATUS_ADDR;
            elsif(present_gen_state = BIT_STATUS) new_par_id <= BIT_STATUS_ADDR;
            elsif(present_gen_state = FPGA_TEMP)  new_par_id <= FPGA_TEMP_ADDR;
            elsif(present_gen_state = CARD_TEMP)  new_par_id <= CARD_TEMP_ADDR;
            elsif(present_gen_state = CYC_OO_SYC) new_par_id <= CYC_OO_SYC_ADDR;
            end if;
            case card_addr_i is
               when NO_CARDS;
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC | BCS | RCS | ALL_FBGA_CARDS | ALL_CARDS =>
                  uop_counter <= uop_counter + 1;
                  insert_uop_rdy <= '1';

--                  if(free_ptr = H0XFF)
--                     free_ptr <= H0X00;
--                  else
--                     free_ptr <= free_ptr + 1;
--                  end if;

                  if(card_addr_i = BCS)
                     if(new_card_addr = BCS)
                        new_card_addr <= BC1;
                     elsif(new_card_addr = BC1)
                        new_card_addr <= BC2;
                     elsif(new_card_addr = BC2)
                        new_card_addr <= BC3;
                     end if;
                  elsif(card_addr_i = RCS)
                     if(new_card_addr = RCS)
                        new_card_addr <= RC1;
                     elsif(new_card_addr = RC1)
                        new_card_addr <= RC2;
                     elsif(new_card_addr = RC2)
                        new_card_addr <= RC3;
                     elsif(new_card_addr = RC3)
                        new_card_addr <= RC3;
                     end if;
                  elsif(card_addr_i = ALL_FBGA_CARDS)
                     if(new_card_addr = ALL_CARDS)
                        new_card_addr <= CC;
                     elsif(new_card_addr = CC)
                        new_card_addr <= RC1;
                     elsif(new_card_addr = RC1)
                        new_card_addr <= RC2;
                     elsif(new_card_addr = RC2)
                        new_card_addr <= RC3;
                     elsif(new_card_addr = RC3)
                        new_card_addr <= RC4;
                     elsif(new_card_addr = RC4)
                        new_card_addr <= BC1;
                     elsif(new_card_addr = BC1)
                        new_card_addr <= BC2;
                     elsif(new_card_addr = BC2)
                        new_card_addr <= BC3;
                     elsif(new_card_addr = BC3)
                        new_card_addr <= AC;
                     end if;
                  elsif(card_addr_i = ALL_CARDS)
                     if(new_card_addr = ALL_CARDS)
                        new_card_addr <= PSC;
                     elsif(new_card_addr = PSC)
                        new_card_addr <= CC;
                     elsif(new_card_addr = CC)
                        new_card_addr <= RC1;
                     elsif(new_card_addr = RC1)
                        new_card_addr <= RC2;
                     elsif(new_card_addr = RC2)
                        new_card_addr <= RC3;
                     elsif(new_card_addr = RC3)
                        new_card_addr <= RC4;
                     elsif(new_card_addr = RC4)
                        new_card_addr <= BC1;
                     elsif(new_card_addr = BC1)
                        new_card_addr <= BC2;
                     elsif(new_card_addr = BC2)
                        new_card_addr <= BC3;
                     elsif(new_card_addr = BC3)
                        new_card_addr <= AC;
                     end if;
                  end if;
               when others; -- Invalid card address
            end case;
         when SINGLE =>
            uop_counter <= uop_counter + 1;
            mop_ack_o <= '0';
            insert_uop_rdy <= '1';
            new_card_addr <= card_addr_i;
--            if(free_ptr = H0XFF)
--               free_ptr <= H0X00;
--            else
--               free_ptr <= free_ptr + 1;
--            end if;
         when CLEANUP =>
            mop_ack_o <= '1';
            insert_uop_rdy <= '0';
            new_card_addr <= card_addr_i;
         when others; -- Normal insertion
      end case;
   end process state_out;

   -- Send FSM:
   send_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_send_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_send_state <= next_send_state;
      end if;
   end process send_state_FF;

   send_state_NS: process(present_send_state, send_ptr, free_ptr, sync_tog, qa, uop_pending, clk_count)
   begin
      case present_send_state is
         when IDLE =>
            -- If there is a u-op waiting to be issued, load it.  If not, idle
            if(send_ptr != free_ptr)
               next_send_state <= LOAD;
            elsif(send_ptr = free_ptr)
               next_send_state <= IDLE;
            end if;
         when LOAD =>
            -- Assert the data address, and retrieve the next u-op
            next_send_state <= VERIFY;
         when VERIFY =>
            if(uop_send_expired = '1')
               -- If the u-op has expired, it should be skipped
               next_send_state <= SKIP;
            elsif(qa(UOP_END-1 downto ISSUE_SYNC_END) = issue_sync_i and clk_count < START_OF_BLACKOUT)
               -- If the u-op can be issued during this sync period, and if the remaining cycle time is sufficient to send the instruction, issue.  Else skip.
               next_send_state <= ISSUE;
            else
               -- If the u-op is still good, but isn't supposed to be issued yet, stay in VERIFY
               next_send_state <= VERIFY;
            end if;
         when ISSUE =>
            next_send_state <= WAIT_FOR_ACK;
            -- Clock the instruction out over the LVDS lines.
         when WAIT_FOR_ACK =>
            if(tx_uop_ack = '1')
               next_send_state <= SKIP;
            elsif(tx_uop_ack = '0')
               next_send_state <= WAIT_FOR_ACK;
            end if;
         when SKIP =>
            -- Skip to the next u-op
            next_send_state <= IDLE;
         when others =>
      end case;
   end process send_state_NS;

   send_state_out: process(present_send_state)
   begin
      uop_send_expired <= '1' when (sync_count_sig > qa(UOP_END        - 1 downto ISSUE_SYNC_END  ) or
                                   (sync_count_sig < qa(UOP_END        - 1 downto ISSUE_SYNC_END  ) and
                                   (MAX_SYNC_COUNT - qa(UOP_END        - 1 downto ISSUE_SYNC_END  ) + sync_count_sig > TIMEOUT_LEN)) else '0';
      rdaddress_a_sig <= send_ptr;
      case present_send_state is
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
            if(send_ptr >= QUEUE_LEN-1)
               send_ptr <= H0X00;
            else
               send_ptr <= send_ptr + 1;
            end if;
         when others;
      end case;
   end process send_state_out;
end behav;