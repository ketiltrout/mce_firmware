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
-- $Id: cmd_queue.vhd,v 1.3 2004/05/13 00:08:30 bburger Exp $
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

entity cmd_queue is
--generic(
--   ADDR_WIDTH     : integer := WB_ADDR_WIDTH;
--   DATA_WIDTH     : integer := WB_DATA_WIDTH;
--   TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
--   );
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
   clk_i        : in std_logic -- advances the state machines
   );
end cmd_queue;

architecture behav of cmd_queue is

constant HIGH : std_logic := '1';
constant LOW : std_logic := '0';
constant H0X00 : std_logic_vector := '00000000';
constant H0XFF : std_logic_vector := '11111111';

constant QUEUE_LEN   : integer  := 256; -- the u-op queue is 256 entries long
constant QUEUE_WIDTH : integer  := 40; -- the u-op queue is 40 bits wide

constant ISSUE_SYNC_BUS_WIDTH   := 8;  -- the width of the data field for the absolute sync count at which an instruction was issued
constant TIMEOUT_SYNC_BUS_WIDTH := 8;  -- the width of the data field for the absolute sync count at which an instruction expires

constant TIMEOUT_LEN : std_logic_vector(7 downto 0) := 1;  -- the number of sync pulses after which an instruction will expire

-- Calculated constants for inputing data on the correct lines into/outof the queue
constant MOP_END          := QUEUE_WIDTH - MOP_BUS_WIDTH;
constant UOP_END          := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH;
constant ISSUE_SYNC_END   := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH;
constant TIMEOUT_SYNC_END := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH - TIMEOUT_SYNC_BUS_WIDTH;
constant CARD_ADDR_END    := QUEUE_WIDTH - MOP_BUS_WIDTH - UOP_BUS_WIDTH - ISSUE_SYNC_BUS_WIDTH - TIMEOUT_SYNC_BUS_WIDTH - CARD_ADDR_BUS_WIDTH;

signal inserted: std_logic;
signal retired : std_logic:
signal sync_count_sig : std_logic_vector(7 downto 0);

-- Command queue inputs/ouputs
signal data_sig        : out std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal wraddress_sig   : out std_logic_vector(7 downto 0);
signal rdaddress_a_sig : out std_logic_vector(7 downto 0);
signal rdaddress_b_sig : out std_logic_vector(7 downto 0);
signal wren_sig        : out std_logic;
--signal rden_a_sig      : out std_logic;
--signal rden_b_sig      : out std_logic;
signal clock_sig       : out std_logic;
--signal enable_sig      : out std_logic;
signal qa_sig          : in std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal qb_sig          : in std_logic_vector(QUEUE_WIDTH-1 downto 0);

-- Command queue management variables
variable uops_generated : integer;
variable cards_addressed : integer;
variable num_uops : integer;
variable queue_space : integer := QUEUE_LEN;

variable retire_ptr : std_logic_vector(7 downto 0) := 0;
variable flush_ptr : std_logic_vector(7 downto 0) := 0;
variable send_ptr : std_logic_vector(7 downto 0) := 0;
variable free_ptr : std_logic_vector(7 downto 0) := 0;

-- Retire state machine:
-- State encoding and state variables:
type retire_states is (IDLE, NEXT_UOP, STATUS, RETIRE, FLUSH, NEXT_FLUSH, FLUSH_STATUS, FLUSH_DONE);
signal present_retire_state : retire_states;
signal next_retire_state    : retire_states;

-- Generate u-Op state machine:
-- State encoding and state variables:
type gen_uop_states is (IDLE, PARSE, INSERT);
signal present_gen_state : gen_uop_states;
signal next_gen_state    : gen_uop_states;
signal mop_rdy : std_logic;

-- Send state machine:
-- State encoding and state variables:
type send_states is (IDLE, VERIFY, ISSUE);
signal present_send_state : send_states;
signal next_send_state    : send_states;

-- Synch detection state machine
-- State encoding and state variables
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
      generic(MAX : integer := 255);
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
               next_gen_state <= INSERT;
            elsif(queue_space >= num_uops) then
               next_gen_state <= PARSE;
         when INSERT => next_gen_state <= IDLE;
         when others next_gen_state <= IDLE;
      end case;
   end process state_NS;

   gen_state_out: process(present_state, )
   begin
      case present_state is
         when IDLE =>
            mop_ack_o <= '0';
         when PARSE =>
            mop_ack_o <= '1';
         when INSERT =>
            mop_ack_o <= '1';

            -- add new u-ops to the queue
            case card_addr_i is
               when NO_CARDS;
               when PSC | CC | RC1 | RC2 | RC3 | RC4 | BC1 | BC2 | BC3 | AC;
                  case par_id_i is
                     when RET_DAT_ADDR =>


                        ;
                     when STATUS_ADDR =>;
                     when others;  -- just convert the m-op directly into a u-op
                  end case;
               when BCS;
               when RCS;
               when ALL_FBGA_CARDS;
               when ALL_CARDS;
               when others; -- invalid card address
            end case;





         when others mop_ack_o <= '0';
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

   function add_uop(new_uop_val: in std_logic_vector(UOP_BUS_WIDTH downto 0)) is
   begin
      data_sig(QUEUE_WIDTH - 1 downto MOP_END)             <= mop_i;
      data_sig(MOP_END - 1 downto UOP_END)                 <= new_uop_val; -- new u-op #
      data_sig(UOP_END - 1 downto ISSUE_SYNC_END)          <= H0X00 when toggle_sync_i = '0' else H0XFF;
      data_sig(ISSUE_SYNC_END - 1 downto TIMEOUT_SYNC_END) <= sync_count_sig + TIMEOUT_LEN;
      data_sig(TIMEOUT_SYNC_END - 1 downto CARD_ADDR_END)  <= card_addr_i;
      data_sig(CARD_ADDR_END - 1 downto 0)                 <= par_id_i;
      wraddress_sig                                        <= free_ptr;
      wren_sig                                             <= '1';
      inserted                                             <= '1';

      -- The RAM block and the functions that write to it will be operating at higher speed than the rest of the logic
      -- After a little while:
      free_ptr <= free_ptr + 1;
      wren_sig <= '0';
      inserted <= '0';
   end add_uop

   function read_uop1 is
   begin

   end read_uop1

   function read_uop2 is
   begin
   end read_uop2



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