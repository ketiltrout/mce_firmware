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
-- $Id: cmd_queue.vhd,v 1.4 2004/05/14 21:40:52 bburger Exp $
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
   mop_o        : out std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- tells the reply_queue the next m-op that the cmd_queue wants to retire
   uop_o        : out std_logic_vector (UOP_BUS_WIDTH-1 downto 0); -- tells the reply_queue the next u-op that the cmd_queue wants to retire
   uop_status_i : in std_logic_vector (UOP_STATUS_BUS_WIDTH-1 downto 0); -- tells the cmd_queue whether a reply was successful or erroneous
   uop_rdy_o    : in std_logic; -- tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   uop_ack_i    : out std_logic; -- tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on rq_uop_status_i
   discard_o    : out std_logic; -- tells the reply_queue whether or not to discard the reply to the current u-op reply when rq_rdy_i goes low.  rq_rdy_o can only go low after rq_ack_o has been received.

   -- cmd_translator interface
   card_addr_i  : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- the card address of the m-op
   par_id_i     : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- the parameter id of the m-op
   cmd_size_i   : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- the number of bytes of data in the m-op
   data_i       : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- data belonging to a m-op
   mop_i        : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- m-op sequence number
   toggle_sync_i: in std_logic; -- bit will be toggled with each new m-op that belongs to a different sync period
   mop_rdy_i    : in std_logic; -- tells cmd_queue when a m-op is ready
   mop_ack_o    : out std_logic; -- tells the cmd_translator when cmd_queue has taken the m-op

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

   -- clock lines
   sync_i       : in std_logic; -- the sync pulse determines when and when not to issue u-ops
   clk_i        : in std_logic; -- advances the state machines
   fast_clk_i   : in std_logic  -- fast clock used for doing multi-cycle operations (inserting and deleting u-ops from the command queue) in a single clk_i cycle.  fast_clk_i must be at least 2x as fast as clk_i
   );
end cmd_queue;

architecture behav of cmd_queue is

constant HIGH : std_logic := '1';
constant LOW : std_logic := '0';
constant H0X00 : std_logic_vector(7 downto 0) := "00000000";
constant H0XFF : std_logic_vector(7 downto 0) := "11111111";

constant QUEUE_LEN   : integer  := 256; -- the u-op queue is 256 entries long
constant QUEUE_WIDTH : integer  := 40; -- the u-op queue is 40 bits wide
constant ISSUE_SYNC_BUS_WIDTH : integer := 8;  -- the width of the data field for the absolute sync count at which an instruction was issued
constant TIMEOUT_SYNC_BUS_WIDTH : integer := 8;  -- the width of the data field for the absolute sync count at which an instruction expires
constant TIMEOUT_LEN : std_logic_vector(7 downto 0) := "00000001";  -- the number of sync pulses after which an instruction will expire

-- Calculated constants for inputing data on the correct lines into/outof the queue
constant MOP_END          : integer := QUEUE_WIDTH - MOP_BUS_WIDTH;
constant UOP_END          : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH;
constant ISSUE_SYNC_END   : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH;
constant TIMEOUT_SYNC_END : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH - TIMEOUT_SYNC_BUS_WIDTH;
constant CARD_ADDR_END    : integer := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH - TIMEOUT_SYNC_BUS_WIDTH - CARD_ADDR_BUS_WIDTH;

-- Command queue inputs/ouputs
signal data_sig        : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal wraddress_sig   : std_logic_vector(7 downto 0);
signal rdaddress_a_sig : std_logic_vector(7 downto 0);
signal rdaddress_b_sig : std_logic_vector(7 downto 0);
signal wren_sig        : std_logic;
--signal rden_a_sig      : out std_logic;
--signal rden_b_sig      : out std_logic;
signal clock_sig       : std_logic;
--signal enable_sig      : out std_logic;
signal qa_sig          : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal qb_sig          : std_logic_vector(QUEUE_WIDTH-1 downto 0);

-- inputs to the FSM that records the number u-op contained in the u-op queue
signal inserted: std_logic;
signal retired : std_logic;
variable uop_counter : std_logic_vector(UOP_BUS_WIDTH downto 0);

-- records the absolute sync count number.  This is used to determine when to issue u-ops and when they have expired.
signal sync_count_sig : std_logic_vector(7 downto 0);

-- Command queue management variables
variable uops_generated : integer;
variable cards_addressed : integer;
variable num_uops : integer;
variable queue_space : integer := QUEUE_LEN;

-- Command queue address pointers.  Each one of these are managed a little differently
variable retire_ptr : std_logic_vector(7 downto 0) := "00000000";
variable flush_ptr : std_logic_vector(7 downto 0) := "00000000";
variable send_ptr : std_logic_vector(7 downto 0) := "00000000";
variable free_ptr : std_logic_vector(7 downto 0) := "00000000";

-- Queue insertion state machine:
signal insert_uop_rdy : std_logic;
signal new_card_addr : std_logic_vector(CARD_ADDR_BUS_WIDTH-1 downto 0);
signal new_par_id : std_logic_vector(PAR_ID_BUS_WIDTH-1 downto 0);
type insert_states is (IDLE, INSERT, DONE);
signal present_insert_state : insert_states;
signal next_insert_state : insert_states;

-- Retire state machine:
type retire_states is (IDLE, NEXT_UOP, STATUS, RETIRE, FLUSH, NEXT_FLUSH, FLUSH_STATUS, FLUSH_DONE);
signal present_retire_state : retire_states;
signal next_retire_state    : retire_states;

-- Generate u-Op state machine:
type gen_uop_states is (IDLE, PARSE, INSERT, RET_DAT, PSC_STATUS, BIT_STATUS, FPGA_TEMP, CARD_TEMP, CARD_ID, CARD_TYPE, SLOT_ID, FMWR_VRSN, DIP, CYC_OO_SYC, SINGLE, CLEANUP);
signal present_gen_state : gen_uop_states;
signal next_gen_state    : gen_uop_states;
signal mop_rdy : std_logic;

-- Send state machine:
type send_states is (IDLE, VERIFY, ISSUE);
signal present_send_state : send_states;
signal next_send_state    : send_states;

-- Synch detection state machine
type synch_states is (IDLE, DETECT);
signal present_sync_state : synch_states;
signal next_sych_state    : synch_states;

begin
   -- command queue (FIFO)
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
      generic map(MAX => 255)
      port map(
         clk_i   => sync_i,
         rst_i   => LOW,
         ena_i   => HIGH,
         load_i  => LOW,
         down_i  => LOW,
         count_i => H0X00,
         count_o => sync_count_sig
      );

   -- counter for tracking free space in the queue:
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

   -- state machine for inserting u-ops into the u-op queue
   insert_state_FF: process(fast_clk_i, rst_i)
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
            -- the gen_state FSM will only try to add a u-op to the queue if there is space available, so no checking is necessary here.  i.e. no ack signal is required
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
            data_sig(UOP_END - 1 downto ISSUE_SYNC_END)          <= H0X00 when toggle_sync_i = '0' else H0XFF;
            data_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) <= sync_count_sig + TIMEOUT_LEN;
            data_sig(TIMEOUT_SYNC_END - 1 downto CARD_ADDR_END)  <= new_card_addr;
            data_sig(CARD_ADDR_END - 1 downto 0)                 <= new_par_id;
            wraddress_sig                                        <= free_ptr;
            wren_sig                                             <= '1';
            inserted                                             <= '1';
         when DONE =>
            -- After adding a new u-op:
            free_ptr <= free_ptr + 1;
            uop_counter <= uop_counter + 1;
            wren_sig <= '0';
            inserted <= '0';
         when others =>
            wren_sig <= '0';
            inserted <= '0';
   end process insert_state_out;

   -- state machine for retiring u-ops:
   retire_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_retire_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_retire_state <= next_retire_state;
      end if;
   end process retire_state_FF;

   -- state machine for generating u-ops:
   gen_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_gen_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_gen_state <= next_gen_state;
      end if;
   end process gen_state_FF;

   gen_state_NS: process(present_gen_state, mop_rdy, queue_space)
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
         when RET_DAT =>
            case card_addr_i is
               when NO_CARDS =>
                  next_gen_state <= PSC_STATUS;
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC =>
                  next_gen_state <= PSC_STATUS;
               when BCS | RCS | ALL_FBGA_CARDS | ALL_CARDS =>
                  -- Only switch to the next command state when finished issuing u-ops to all the cards that must receive this command
                  if((card_addr_i = BCS and new_card_addr = BC3) or
                     (card_addr_i = RCS and new_card_addr = RC4) or
                     (card_addr_i = ALL_FBGA_CARDS and new_card_addr = AC) or
                     (card_addr_i = ALL_CARDS and new_card_addr = AC))
                     next_gen_state <= PSC_STATUS;
                  end if;
               when others =>
                  next_gen_state <= CLEANUP;
            end case;
         when PSC_STATUS =>
         when BIT_STATUS =>
         when FPGA_TEMP =>
         when CARD_TEMP =>
         when CYC_OO_SYC =>
            case card_addr_i is
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC =>
                  if(par_id_i = RET_DATA_ADDR)
                     next_gen_state <= CLEANUP;
                  elsif(par_id_i = STATUS_ADDR)
                     next_gen_state <= CARD_ID;
                  end if;
               when BCS | RCS | ALL_FBGA_CARDS | ALL_CARDS =>
                  -- Only switch to the next command state when finished issuing u-ops to all the cards that must receive this command
                  if((card_addr_i = BCS and new_card_addr = BC3) or
                     (card_addr_i = RCS and new_card_addr = RC4) or
                     (card_addr_i = ALL_FBGA_CARDS and new_card_addr = AC) or
                     (card_addr_i = ALL_CARDS and new_card_addr = AC))
                     if(par_id_i = RET_DATA_ADDR)
                        next_gen_state <= CLEANUP;
                     elsif(par_id_i = STATUS_ADDR)
                        next_gen_state <= CARD_ID;
                     end if;
                  end if;
               when others =>
                  next_gen_state <= CLEANUP;
            end case;
         when CARD_ID =>
         when CARD_TYPE =>
         when SLOT_ID =>
         when FMWR_VRSN =>
         when DIP =>
         when SINGLE => -- Single card, single instruction
         when CLEANUP =>
         when others next_gen_state <= IDLE;
      end case;
   end process state_NS;

   gen_state_out: process(present_gen_state, )
   begin
      case present_gen_state is
         when IDLE =>
            mop_ack_o <= '0';
            insert_uop_rdy <= '0';
         when PARSE =>
            mop_ack_o <= '0';
            insert_uop_rdy <= '0';
         when INSERT =>
            --mop_ack_o <= '1';
            uop_counter <= (others => '0');
            new_card_addr <= card_addr_i;
            -- add new u-ops to the queue
         when RET_DAT | PSC_STATUS | BIT_STATUS | FPGA_TEMP | CARD_TEMP | CYC_OO_SYC | CARD_ID | CARD_TYPE | SLOT_ID | FMWR_VRSN | DIP =>
            if   (present_gen_state = RET_DATA)   new_par_id <= RET_DAT_ADDR;
            elsif(present_gen_state = PSC_STATUS) new_par_id <= PSC_STATUS_ADDR;
            elsif(present_gen_state = BIT_STATUS) new_par_id <= BIT_STATUS_ADDR;
            elsif(present_gen_state = FPGA_TEMP)  new_par_id <= FPGA_TEMP_ADDR;
            elsif(present_gen_state = CARD_TEMP)  new_par_id <= CARD_TEMP_ADDR;
            elsif(present_gen_state = CYC_OO_SYC) new_par_id <= CYC_OO_SYC_ADDR;
            elsif(present_gen_state = CARD_ID)    new_par_id <= CARD_ID_ADDR;
            elsif(present_gen_state = CARD_TYPE)  new_par_id <= CARD_TYPE_ADDR;
            elsif(present_gen_state = SLOT_ID)    new_par_id <= SLOT_ID_ADDR;
            elsif(present_gen_state = FMWR_VRSN)  new_par_id <= FMWR_VRSN_ADDR;
            elsif(present_gen_state = DIP)        new_par_id <= DIP_ADDR;
            end if;
            case card_addr_i is
               when NO_CARDS;
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC =>
                  uop_counter <= uop_counter + 1;
                  insert_uop_rdy <= '1';
               when BCS;
                  if(new_card_addr = BCS)
                     new_card_addr <= BC1;
                     insert_uop_rdy <= '1';
                     uop_counter <= uop_counter + 1;
                  elsif(new_card_addr = BC1)
                     new_card_addr <= BC2;
                     insert_uop_rdy <= '1';
                     uop_counter <= uop_counter + 1;
                  elsif(new_card_addr = BC2)
                     new_card_addr <= BC3;
                     insert_uop_rdy <= '1';
                     uop_counter <= uop_counter + 1;
                  end if;
               when RCS;
                  if(new_card_addr = RCS)
                     new_card_addr <= RC1;
                     insert_uop_rdy <= '1';
                     uop_counter <= uop_counter + 1;
                  elsif(new_card_addr = RC1)
                     new_card_addr <= RC2;
                     insert_uop_rdy <= '1';
                     uop_counter <= uop_counter + 1;
                  elsif(new_card_addr = RC2)
                     new_card_addr <= RC3;
                     insert_uop_rdy <= '1';
                     uop_counter <= uop_counter + 1;
                  elsif(new_card_addr = RC3)
                     new_card_addr <= RC3;
                     insert_uop_rdy <= '1';
                     uop_counter <= uop_counter + 1;
                  end if;
               when ALL_FBGA_CARDS;
               when ALL_CARDS;
               when others; -- invalid card address
            end case;
         when SINGLE =>
         when CLEANUP =>
            mop_ack_o <= '1';
            insert_uop_rdy <= '0';
         when others; -- Normal insertion
      end case;
   end process state_out;

   -- state machine for sending u-ops:
   send_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_send_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_send_state <= next_send_state;
      end if;
   end process send_state_FF;

   -- state machine for controlling SRAM:
   sync_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_sync_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_sync_state <= next_sync_state;
      end if;
   end process sync_state_FF;

   with card_addr_i(CARD_ADDR_WIDTH-1 downto 0) select
      cards_addressed <=
         0 when NO_CARDS,
         1 when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC,
         3 when BCS,
         4 when RCS,
         9 when ALL_FBGA_CARDS,
         10 when ALL_CARDS,
         0 when others; -- invalid card address

   -- the par_id checking is done in the cmd_translator block.
   -- thus, here I can use the 'when others' case for something other than
   -- error checking, because the par_id that cmd_translator issues to cmd_queue
   -- is always valid.
   with par_id_i select
      uops_generated <=
         10 when RET_DAT_ADDR,
         9 when STATUS_ADDR,
         1 when others; -- all other m-ops generate on u-op

   num_uops <= uops_generated * cards_addressed;
   mop_rdy <= mop_rdy_i;

end behav;













            if(next_gen_state <= IDLE;
            case card_addr_i is
               when NO_CARDS;
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC;
                  case par_id_i is
                     when RET_DAT_ADDR =>
                        add_uop(card_addr_i, RET_DAT_ADDR);
                        add_uop(card_addr_i, BIT_STATUS_ADDR);
                        add_uop(card_addr_i, FPGA_TEMP_ADDR);
                        add_uop(card_addr_i, CARD_TEMP_ADDR);
                        add_uop(card_addr_i, CARD_ID_ADDR);
                        add_uop(card_addr_i, CARD_TYPE_ADDR);
                        add_uop(card_addr_i, SLOT_ID_ADDR);
                        add_uop(card_addr_i, FMWR_VRSN_ADDR);
                        add_uop(card_addr_i, DIP_ADDR);
                        add_uop(card_addr_i, CYC_OO_SYC_ADDR);
                     when STATUS_ADDR =>
                        add_uop(card_addr_i, BIT_STATUS_ADDR);
                        add_uop(card_addr_i, FPGA_TEMP_ADDR);
                        add_uop(card_addr_i, CARD_TEMP_ADDR);
                        add_uop(card_addr_i, CARD_ID_ADDR);
                        add_uop(card_addr_i, CARD_TYPE_ADDR);
                        add_uop(card_addr_i, SLOT_ID_ADDR);
                        add_uop(card_addr_i, FMWR_VRSN_ADDR);
                        add_uop(card_addr_i, DIP_ADDR);
                        add_uop(card_addr_i, CYC_OO_SYC_ADDR);
                     when others => add_uop(card_addr_i);  -- just convert the m-op directly into a u-op if any other m-op is received
                  end case;
               when BCS;
               when RCS;
               when ALL_FBGA_CARDS;
               when ALL_CARDS;
               when others; -- invalid card address
            end case;









   -- Shared registers
   -- retire queue pointer:
   retire_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );

   -- flush queue pointer:
   flush_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );

   -- send queue pointer:
   send_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );

   -- free queue pointer:
   free_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );

   -- frame timeing block
   frame_timer: frame_timing
      port map(clk_i       => clk_i,
               sync_i      => sync_i,
               frame_rst_i => ,
               clk_count_o => ,
               clk_error_o => );