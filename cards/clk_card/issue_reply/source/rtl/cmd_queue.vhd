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
-- $Id: cmd_queue.vhd,v 1.74 2004/12/16 22:05:40 bburger Exp $
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
-- Revision 1.74  2004/12/16 22:05:40  bburger
-- Bryce:  changes associated with lvds_tx and cmd_translator interface changes
--
-- Revision 1.73  2004/12/14 06:01:23  bburger
-- Bryce:  Fixed a bug in the cmd_queue retire FSM that didn't allow the pointer to wrap properly
--
-- Revision 1.72  2004/12/13 06:43:44  bburger
-- Bryce:  Changed the RAM memory management
--
-- Revision 1.71  2004/12/10 22:51:45  bburger
-- Bryce:  nothing, really..
--
-- Revision 1.70  2004/12/08 22:16:23  bburger
-- Bryce:  replaced a retire_ptr recirc-mux that was causing compilation problems in Quartus
--
-- Revision 1.69  2004/12/06 07:23:04  bburger
-- Bryce:  Modified cmd_queue and reply_queue stop them from allowing start commands over the backplane
--
-- Revision 1.68  2004/12/04 02:03:05  bburger
-- Bryce:  fixing some problems associated with integrating the reply_queue
--
-- Revision 1.67  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.66  2004/11/25 01:32:37  bburger
-- Bryce:
-- - Changed to cmd_code over the bus backplane to read/write only
-- - Added interface signals for internal commands
-- - RB command data-sizes are correctly handled
--
-- Revision 1.65  2004/11/16 09:03:20  bburger
-- Bryce :  removed status_addr from ISA!
--
-- Revision 1.64  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.63  2004/11/15 19:32:07  bburger
-- Bryce : fixed a bug that affected the uop_rdy_o signal
--
-- Revision 1.62  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
-- Revision 1.61  2004/10/26 23:59:16  bburger
-- Bryce:  working out the bugs from the cmd_queue<->reply_queue interface
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
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.cmd_queue_ram40_pack.all;
use work.sync_gen_pack.all;
use work.async_pack.all;
use work.cmd_queue_pack.all;
use work.frame_timing_pack.all;

entity cmd_queue is
   port(
      -- for testing
      debug_o  : out std_logic_vector(31 downto 0);

      -- reply_queue interface
      uop_rdy_o       : out std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
      uop_ack_i       : in std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
      uop_o           : out std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

      -- cmd_translator interface
      card_addr_i     : in std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0); -- The card address of the m-op
      par_id_i        : in std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0); -- The parameter id of the m-op
      data_size_i     : in std_logic_vector(FIBRE_DATA_SIZE_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
      data_i          : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- Data belonging to a m-op
      data_clk_i      : in std_logic; -- Clocks in 32-bit wide data
      mop_i           : in std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0); -- M-op sequence number
      issue_sync_i    : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      mop_rdy_i       : in std_logic; -- Tells cmd_queue when a m-op is ready
      mop_ack_o       : out std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op
      cmd_type_i      : in std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_i      : in std_logic;                                          -- indicates a STOP command was recieved
      last_frame_i    : in std_logic;                                          -- indicates the last frame of data for a ret_dat command
      frame_seq_num_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_i  : in std_logic;

      -- lvds_tx interface
      tx_o            : out std_logic;  -- transmitter output pin

      -- frame_timing interface
      sync_i          : in std_logic; -- The sync pulse determines when and when not to issue u-ops
      sync_num_i      : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Clock lines
      clk_i           : in std_logic; -- Advances the state machines
      mem_clk_i    : in std_logic;  -- PLL locked 25MHz input clock for the
      rst_i           : in std_logic  -- Resets all FSMs
   );
end cmd_queue;

architecture behav of cmd_queue is

constant ADDR_ZERO          : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0) := (others => '0');
constant ADDR_FULL_SCALE    : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0) := (others => '1');
constant TIMEOUT_LEN        : std_logic_vector(ISSUE_SYNC_WIDTH-1 downto 0) := x"0001";  -- The number of sync pulses after which an instruction will expire
--constant MAX_SYNC_COUNT     : integer := 255;

-- Command queue inputs/ouputs (this interface was generated by a Quartus II megafunction for a RAM block)
signal data_sig             : std_logic_vector(QUEUE_WIDTH-1 downto 0);

signal wraddress_sig        : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal rdaddress_a_sig      : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal rdaddress_b_sig      : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal wren_sig             : std_logic;
signal qa_sig               : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal qb_sig               : std_logic_vector(QUEUE_WIDTH-1 downto 0);

-- Sync-pulse counter inputs/outputs.  These are used to determine when u-ops have expired.
signal sync_count_slv       : std_logic_vector(ISSUE_SYNC_WIDTH-1 downto 0);

-- Command queue management variables
signal uops_generated       : integer;
signal cards_addressed      : integer;
signal num_uops             : integer;
signal data_size_int        : integer;
signal size_uops            : integer;
signal num_uops_inserted    : integer; --determines when to stop inserting u-ops
signal queue_space          : integer;
signal num_uops_contained   : integer;
signal num_uops_contained_mux : integer;

-- Command queue address pointers.  Each one of these are managed by a different FSM.
signal retire_ptr           : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal send_ptr             : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal free_ptr             : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);

-- Insertion FSM:  inserts u-ops into the command queue
type insert_states is (IDLE, INSERT_HDR1, INSERT_HDR2, INSERT_HDR3, INSERT_HDR4, INSERT_DATA, INSERT_MORE_DATA, DONE, DATA_STROBE_DETECT, LATCHED_DATA);
signal present_insert_state : insert_states;
signal next_insert_state    : insert_states;
signal data_count           : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal insert_uop_ack       : std_logic; --tells the generate FSM when the insert FSM is ready to insert the next u-op
signal num_uops_inserted_slv: std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
signal one_more             : std_logic;

-- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
type retire_states is (FIRST_IDLE, IDLE, NEXT_UOP, STATUS, RETIRE, HEADER_A, HEADER_B, HEADER_C, HEADER_D, SKIP_UOP);
signal present_retire_state : retire_states;
signal next_retire_state    : retire_states;
signal retired              : std_logic; --Out, to the u-op counter fsm
signal uop_to_retire        : std_logic;
signal retire_data_size_int : integer;
signal retire_data_size_en  : std_logic;
signal retire_data_size     : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal one_less             : std_logic;
signal retire_cmd_code_en   : std_logic;
signal retire_cmd_code      : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);

-- Generate FSM:  translates M-ops into u-ops
type gen_uop_states is (IDLE, INSERT, CLEANUP, DONE);
signal present_gen_state    : gen_uop_states;
signal next_gen_state       : gen_uop_states;
signal mop_rdy              : std_logic; --In from the previous block in the chain  
signal insert_uop_rdy       : std_logic; --Out, to insertion fsm, tells the insert FSM when a new u-op is available
signal new_card_addr        : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); --out, to insertion fsm
signal new_par_id           : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); --out, to insertion fsm.  This is a hack.
signal data_size_reg        : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal data_size_mux        : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal data_size_mux_sel    : std_logic;

-- Send FSM:  sends u-ops over the bus backplane
type send_states is (LOAD, BUFFER_CMD_PARAM, ISSUE, HEADER_A, HEADER_B, HEADER_C, HEADER_D, DATA, MORE_DATA, CHECKSUM, NEXT_UOP, PAUSE, BRANCH, LATCH_CRC);
signal present_send_state   : send_states;
signal next_send_state      : send_states;
signal previous_send_state  : send_states;
signal update_prev_state    : std_logic;
signal freeze_send          : std_logic;  --In, freezes the send pointer when flushing out invalidated u-ops
signal uop_send_expired     : std_logic;
signal issue_sync           : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
signal timeout_sync         : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
signal send_data_size_int   : integer;
signal uop_data_count       : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal send_cmd_code_en     : std_logic;
signal send_cmd_code        : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);
signal bb_cmd_code          : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);
signal send_data_size_en    : std_logic;
signal send_data_size       : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);

-- Wishbone signals to/from lvds_tx
signal cmd_tx_dat           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal lvds_tx_rdy          : std_logic;
signal lvds_tx_busy         : std_logic;

-- CRC signals:
signal crc_clr              : std_logic;
signal crc_ena              : std_logic;
signal crc_data             : std_logic;
signal crc_num_bits         : integer;
signal crc_done             : std_logic;
signal crc_valid            : std_logic;
signal crc_checksum         : std_logic_vector(CHECKSUM_WORD_WIDTH-1 downto 0);
signal crc_reg              : std_logic_vector(CHECKSUM_WORD_WIDTH-1 downto 0);

-- Shift Register signals:
signal sh_reg_serial_o      : std_logic;
signal sh_reg_parallel_i    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal sh_reg_parallel_o    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); --Dummy signal

-- Bit Counter signals
signal bit_ctr_count        : integer;
signal bit_ctr_ena          : std_logic; -- enables the counter which controls the enable line to the CRC block.  The counter should only be functional when there is a to calculate.
signal bit_ctr_load         : std_logic; --Not part of the interface to the crc block; enables sh_reg and bit_ctr.

-- Constants that can be removed when the sync_counter and frame_timer are moved out of this block
constant HIGH               : std_logic := '1';
constant LOW                : std_logic := '0';
constant INT_ZERO           : integer := 0;

-- [JJ]
signal queue_space_mux      : integer;
signal queue_space_mux_sel  : std_logic_vector(2 downto 0);

signal data_sig_mux         : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal data_sig_mux_sel     : std_logic_vector(2 downto 0);

signal data_count_mux       : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0); 
signal data_count_mux_sel   : std_logic_vector(1 downto 0);

signal free_ptr_mux_sel     : std_logic_vector(1 downto 0);
--signal free_ptr_reg          : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);

signal retire_ptr_mux_sel   : std_logic_vector(2 downto 0);

signal current_par_id      : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);

signal new_par_id_mux_sel           : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);

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
--signal crc_num_bits2        : integer;

signal cmd_tx_dat_mux_sel   : std_logic_vector(2 downto 0);
signal cmd_tx_dat_reg       : std_logic_vector(31 downto 0);

--signal send_ptr_reg           : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
signal send_ptr_mux_sel       : std_logic_vector(2 downto 0);

signal uop_data_count_mux_sel : std_logic_vector(1 downto 0);
signal uop_data_count_reg     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

--signal uop_data_size_mux_sel  : std_logic_vector(1 downto 0);
--signal uop_data_size_reg      : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

signal sh_reg_parallel_mux_sel: std_logic_vector(1 downto 0);

type queue_state is           (INIT1, INIT2, DONE);
signal queue_next_state, queue_cur_state : queue_state;
signal queue_init_value_sel   : std_logic;



begin

------------------------------------------------------------------------
--
-- instantiations
--
------------------------------------------------------------------------ 

   -- For hardware integration with the logic analyzer
   --debug_o(31 downto 0)  <=  clk_i & "000000000" & lvds_tx_rdy & lvds_tx_busy & uop_data_size(3 downto 0) & prev_send_state & send_state & cmd_tx_dat(31 downto 24);
   debug_o(31 downto 0)  <=  cmd_tx_dat(31 downto 1) & lvds_tx_busy;
      
   -- Command queue (FIFO)
   cmd_queue_ram40_inst: cmd_queue_tpram
      port map(
         data        => data_sig,
         wraddress   => wraddress_sig,
         rdaddress_a => rdaddress_a_sig,
         rdaddress_b => rdaddress_b_sig,
         wren        => wren_sig,
         clock       => mem_clk_i,  
         qa          => qa_sig, -- qa_sig data are used by the send FSM         
         qb          => qb_sig -- qb_sig data are used by the retire FSM
      );

   -- lvds_tx is the LVDS interface to the Bus Backplane
   cmd_tx2: lvds_tx
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         dat_i      => cmd_tx_dat,
         rdy_i      => lvds_tx_rdy,
         busy_o     => lvds_tx_busy,
         lvds_o     => tx_o
      );
  
   cmd_crc: crc
      generic map(
         POLY_WIDTH  => CHECKSUM_WORD_WIDTH
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
         WIDTH      => PACKET_WORD_WIDTH
      )   
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => HIGH, --Always enabled      
         load_i     => bit_ctr_load,      
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
         load_i      => bit_ctr_load,
         count_i     => INT_ZERO,
         count_o     => bit_ctr_count
      );

------------------------------------------------------------------------
--
------------------------------------------------------------------------ 

   -- Counter for tracking free space in the queue:
   space_calc: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         queue_space     <= QUEUE_LEN;
         queue_cur_state <= INIT1;
         num_uops_contained <= 0;
      elsif(clk_i'event and clk_i = '1') then
         queue_space     <= queue_space_mux;
         queue_cur_state <= queue_next_state;
         num_uops_contained <= num_uops_contained_mux;
      end if;
   end process;
   
   retire_data_size_int <= conv_integer(retire_data_size);
   
   num_uops_contained_mux <= 
      num_uops_contained when one_more = '0' and one_less = '0' else
      num_uops_contained+1 when one_more = '1' and one_less = '0' else
      num_uops_contained-1 when one_more = '0' and one_less = '1' else
      num_uops_contained when one_more = '1' and one_less = '1';
      
   queue_space_mux <= queue_space when queue_space_mux_sel = "000" else
                      queue_space + CQ_NUM_CMD_HEADER_WORDS + retire_data_size_int when queue_space_mux_sel = "001" else
                      queue_space - 1 when queue_space_mux_sel = "010" else
                      queue_space + CQ_NUM_CMD_HEADER_WORDS + retire_data_size_int - 1 when queue_space_mux_sel = "011" else
                      QUEUE_LEN when queue_space_mux_sel = "100";
                        
   queue_space_mux_sel <= "100" when queue_init_value_sel = '1' else '0' & wren_sig & retired;

   -- Initialization logic for queue_space to set it to 255 on startup
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
         present_insert_state <= IDLE;
         free_ptr <= ADDR_ZERO;
         
      elsif(clk_i'event and clk_i = '1') then
         present_insert_state <= next_insert_state;
         
         if(free_ptr_mux_sel = "00") then
            free_ptr <= free_ptr;
         elsif(free_ptr_mux_sel = "01") then
            free_ptr <= free_ptr + 1;
         elsif(free_ptr_mux_sel = "10") then
            free_ptr <= ADDR_ZERO;
         else
            free_ptr <= free_ptr;
         end if;
         
      end if;
   end process;
   
   insert_state_NS: process(present_insert_state, data_size_i, data_count, data_clk_i, insert_uop_rdy, cmd_type_i)--,mop_rdy_i
   begin
      next_insert_state <= present_insert_state;
      case present_insert_state is
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
            next_insert_state <= INSERT_HDR3;
         when INSERT_HDR3 =>
            next_insert_state <= INSERT_HDR4;
         when INSERT_HDR4 =>
            if((cmd_type_i = READ_BLOCK) or (data_size_i(BB_DATA_SIZE_WIDTH-1 downto 0) = x"0000")) then
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
            if(data_count < data_size_i(BB_DATA_SIZE_WIDTH-1 downto 0)) then
               next_insert_state <= DATA_STROBE_DETECT;
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

   -- data_sig routing mux
   process(data_sig_mux_sel, issue_sync_i, cmd_type_i, data_size_i, new_card_addr, new_par_id, mop_i, num_uops_inserted_slv, data_i, cmd_stop_i, last_frame_i, frame_seq_num_i, internal_cmd_i)
   begin
      case data_sig_mux_sel is
         when "000" => data_sig_mux <= (others=>'0');
         when "001" => data_sig_mux <= (issue_sync_i & cmd_type_i & data_size_i(BB_DATA_SIZE_WIDTH-1 downto 0));
         when "010" => data_sig_mux <= (new_card_addr & new_par_id & mop_i & num_uops_inserted_slv);
         when "011" => data_sig_mux <= "00000000000000000000000000000" & internal_cmd_i & cmd_stop_i & last_frame_i;
         when "100" => data_sig_mux <= frame_seq_num_i; 
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
     
   data_size_mux  <= data_size_reg when data_size_mux_sel = '0' else data_size_i(BB_DATA_SIZE_WIDTH-1 downto 0);                         

   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         data_count     <= (others=>'0');
--         free_ptr_reg   <= (others=>'0');
         data_size_reg  <= (others => '0');
      elsif clk_i'event and clk_i = '1' then
         data_count     <= data_count_mux;
--         free_ptr_reg   <= free_ptr;
         data_size_reg  <= data_size_mux;
      end if;
   end process;
   
   insert_state_out: process(present_insert_state, data_clk_i, num_uops_inserted, num_uops, data_size_reg, cmd_type_i)
   begin   
      --defaults
      data_sig_mux_sel             <= "000"; -- (others=>'0')
      data_count_mux_sel           <= "00";
      free_ptr_mux_sel             <= "00";
      data_size_mux_sel            <= '0'; -- hold value
      one_more                     <= '0';

      case present_insert_state is
         when IDLE =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "11"; -- default
            mop_ack_o              <= '0';
            insert_uop_ack         <= '0';
            free_ptr_mux_sel       <= "00";
         
         when INSERT_HDR1 =>
            wren_sig               <= '1';
            data_count_mux_sel     <= "11";
            mop_ack_o              <= '0';
            insert_uop_ack         <= '0';
            data_sig_mux_sel       <= "001";
            free_ptr_mux_sel       <= "01";
            data_size_mux_sel      <= '1';
            one_more               <= '1';

         when INSERT_HDR2 =>
            wren_sig               <= '1';
            data_count_mux_sel     <= "11";
            mop_ack_o              <= '0';
            insert_uop_ack         <= '0';
            data_sig_mux_sel       <= "010";
            free_ptr_mux_sel       <= "01";
            
         when INSERT_HDR3 =>
            wren_sig               <= '1';
            data_count_mux_sel     <= "11";
            mop_ack_o              <= '0';
            insert_uop_ack         <= '0';
            data_sig_mux_sel       <= "011";
            free_ptr_mux_sel       <= "01";

         when INSERT_HDR4 =>
            wren_sig               <= '1';
            data_count_mux_sel     <= "11";

            -- Asserting mop_ack_o causes cmd_translator to begin passing data through to cmd_queue.
            -- In this implememtation, data are not replicated for other u-ops, if the m-op generates several u-ops.
            -- This means that all m-ops with data can only generate a single u-op..for now.
            -- If a m-op is issued with data and generated several u-ops, only the last one will have data.
            if(num_uops_inserted = num_uops and data_size_reg /= x"0000" and cmd_type_i /= READ_BLOCK) then
               mop_ack_o           <= '1';
            else 
               mop_ack_o           <= '0';
            end if;
            
            insert_uop_ack         <= '0';
            data_sig_mux_sel       <= "100";
            free_ptr_mux_sel       <= "01";

         when DATA_STROBE_DETECT =>

            if(data_clk_i = '1') then
               wren_sig            <= '1';
               data_count_mux_sel  <= "01";
               mop_ack_o           <= '0';
               insert_uop_ack      <= '0';
               data_sig_mux_sel    <= "111";
               free_ptr_mux_sel    <= "01";
            else
               wren_sig            <= '0';
               data_count_mux_sel  <= "00";
               mop_ack_o           <= '0';
               insert_uop_ack      <= '0';
               data_sig_mux_sel    <= "111";
               free_ptr_mux_sel    <= "00";
            end if;

         when LATCHED_DATA =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "00";
            mop_ack_o              <= '0';
            insert_uop_ack         <= '0';
            data_sig_mux_sel       <= "111";
            free_ptr_mux_sel       <= "00";

         when DONE =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "11";

            -- If there is no data with the m-op, then asserting mop_ack_o in the INSERT_HDR2 state would be too soon
            -- In this case, by delaying its assertion until DONE, we ensure that the cmd_translator doesn't try to insert the next m_op too soon.
            -- I think that I might have to register num_uops_inserted and num_uops to make sure that they are valid when I do this check
            if(num_uops_inserted = num_uops and (data_size_reg = x"0000" or cmd_type_i = READ_BLOCK)) then
               mop_ack_o          <= '1';
            else
               mop_ack_o          <= '0';
            end if;

            insert_uop_ack         <= '1';
            data_sig_mux_sel       <= "000";

-- I think that this is causing a bug            
            -- After adding a new u-op:
--            if(free_ptr = ADDR_FULL_SCALE) then
--               free_ptr_mux_sel    <= "11";
--            else
               free_ptr_mux_sel    <= "00";
--            end if;
            
         when others =>
            wren_sig               <= '0';
            data_count_mux_sel     <= "11";
            mop_ack_o             <= '0';
            insert_uop_ack         <= '0';
            data_sig_mux_sel       <= "000";
            free_ptr_mux_sel       <= "00";

      end case;
   end process;


   -- Retire FSM:
   retire_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_retire_state <= FIRST_IDLE;
         retire_ptr <= ADDR_ZERO;
         uop_to_retire <= '0';
         
      elsif(clk_i'event and clk_i = '1') then
         present_retire_state <= next_retire_state;
         
         -- This logic determines the next value of the retire_ptr
         if(retire_ptr_mux_sel = "000") then
            retire_ptr <= retire_ptr;
         elsif(retire_ptr_mux_sel = "001") then
            retire_ptr <= ADDR_ZERO;
         elsif(retire_ptr_mux_sel = "010") then
            retire_ptr <= retire_ptr + CQ_NUM_CMD_HEADER_WORDS + retire_data_size;
         elsif(retire_ptr_mux_sel = "101") then
            retire_ptr <= retire_ptr + 1;
         elsif(retire_ptr_mux_sel = "110") then
            retire_ptr <= retire_ptr + 1 + retire_data_size;
         else
            retire_ptr <= retire_ptr;
         end if;

         -- This signal is to be used to determine when there is a u-op to retire.  
         -- This signal should not be asserted until the entire u-op pointed to by retire_ptr has been issued (not including the CRC).   
         if((retire_ptr < send_ptr) and (retire_cmd_code /= READ_BLOCK) and (send_ptr - retire_ptr >= CQ_NUM_CMD_HEADER_WORDS + retire_data_size)) then
            uop_to_retire <= '1';
         elsif((retire_ptr > send_ptr) and (retire_cmd_code /= READ_BLOCK) and (retire_ptr - send_ptr <= QUEUE_LEN - CQ_NUM_CMD_HEADER_WORDS - retire_data_size)) then
            uop_to_retire <= '1';
         elsif((retire_ptr < send_ptr) and (retire_cmd_code = READ_BLOCK) and (send_ptr - retire_ptr >= CQ_NUM_CMD_HEADER_WORDS)) then
            uop_to_retire <= '1';
         elsif((retire_ptr > send_ptr) and (retire_cmd_code = READ_BLOCK) and (retire_ptr - send_ptr <= QUEUE_LEN - CQ_NUM_CMD_HEADER_WORDS)) then
            uop_to_retire <= '1';
         else
            uop_to_retire <= '0';
         end if;
         
      end if;
   end process retire_state_FF;

   retire_data_size_reg : reg
      generic map(
         WIDTH      => QUEUE_ADDR_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => retire_data_size_en,
         reg_i      => qb_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END),
         reg_o      => retire_data_size
      );

   retire_cmd_code_reg : reg
      generic map(
         WIDTH => BB_COMMAND_TYPE_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => retire_cmd_code_en,
         reg_i      => qb_sig(ISSUE_SYNC_END-1 downto COMMAND_TYPE_END),
         reg_o      => retire_cmd_code
      );

   retire_state_NS: process(present_retire_state, uop_ack_i, uop_to_retire, send_ptr, retire_ptr, retire_cmd_code)
   begin
      next_retire_state <= present_retire_state;
      case present_retire_state is
         when FIRST_IDLE =>
            if(send_ptr /= retire_ptr) then
               next_retire_state <= IDLE;
            end if;
         
         when IDLE =>
            if(uop_to_retire = '1') then
               if(retire_cmd_code = START or retire_cmd_code = RESET) then
                  next_retire_state <= SKIP_UOP;
               else
                  next_retire_state <= HEADER_B;
               end if;
            end if;
         
         when HEADER_B =>
            next_retire_state <= HEADER_C;
         
         when HEADER_C =>
            next_retire_state <= HEADER_D;
         
         when HEADER_D =>
            next_retire_state <= STATUS;
         
         when STATUS =>
            if(uop_ack_i = '1') then
                  next_retire_state <= RETIRE;
            elsif (uop_ack_i = '0') then
               next_retire_state <= STATUS;
            end if;
         
         when RETIRE =>
            next_retire_state <= FIRST_IDLE;
         
         when SKIP_UOP =>
            next_retire_state <= FIRST_IDLE;
            
         when others =>
            next_retire_state <= FIRST_IDLE;
      end case;
   end process;

   rdaddress_b_sig <= retire_ptr;
   uop_o <= qb_sig;

   retire_state_out: process(present_retire_state, next_retire_state, send_ptr, retire_ptr, retire_cmd_code)
   begin
      -- defaults
      uop_rdy_o      <= '0';
      freeze_send    <= '0';
      retired        <= '0';
      retire_ptr_mux_sel  <= "000"; -- hold value
      retire_data_size_en <= '0';
      retire_cmd_code_en  <= '0';
      one_less            <= '0';
   
      case present_retire_state is
         when FIRST_IDLE =>
            if(send_ptr /= retire_ptr) then
               retire_data_size_en <= '1';
               retire_cmd_code_en  <= '1';
            end if;
         
         when IDLE =>
            if(next_retire_state = HEADER_B) then
               retire_ptr_mux_sel <= "101";
               uop_rdy_o      <= '1';
            else
               uop_rdy_o      <= '0';
            end if;
            
         when HEADER_B =>
            retire_ptr_mux_sel <= "101"; 
            
         when HEADER_C => 
            retire_ptr_mux_sel <= "101"; 

         when HEADER_D =>
            if(retire_cmd_code = READ_BLOCK) then
               retire_ptr_mux_sel <= "101";
            else
               retire_ptr_mux_sel <= "110";
            end if;
            
         when STATUS =>
            
         when RETIRE =>
            retired        <= '1';
            one_less       <= '1';

         when SKIP_UOP =>
            -- We only enter this state if retiring a Reset or a Start command
            retired        <= '1';
            one_less       <= '1';
            retire_ptr_mux_sel <= "010"; 
            
         when others =>
      end case;
   end process;

------------------------------------------------------------------------
--
-- Generate FSM:
--
------------------------------------------------------------------------
   
   gen_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_gen_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_gen_state <= next_gen_state;
      end if;
   end process;

   gen_state_NS: process(present_gen_state, mop_rdy, num_uops_contained, queue_space, size_uops,  
                         insert_uop_ack, num_uops_inserted, num_uops)
   begin
      next_gen_state <= present_gen_state;
      case present_gen_state is
         when IDLE =>
            if(mop_rdy = '0') then
               next_gen_state <= IDLE;
            else   
               if(queue_space >= size_uops and num_uops_contained < MAX_NUM_UOPS) then
                  next_gen_state <= CLEANUP;                  
               else
                  next_gen_state <= IDLE;
               end if;            
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

   with card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0) select
      cards_addressed <=
         0 when NO_CARDS,
         1 when POWER_SUPPLY_CARD | CLOCK_CARD | READOUT_CARD_1 | READOUT_CARD_2 | READOUT_CARD_3 | READOUT_CARD_4 | BIAS_CARD_1 | BIAS_CARD_2 | BIAS_CARD_3 | ADDRESS_CARD,
         3 when ALL_BIAS_CARDS,
         4 when ALL_READOUT_CARDS,
         9 when ALL_FPGA_CARDS,
         10 when ALL_CARDS,
         0 when others; -- invalid card address

   -- The par_id checking is done in the cmd_translator block.
   -- Thus, here I can use the 'when others' case for something other than
   -- error checking, because the par_id that cmd_translator issues to cmd_queue
   -- is always valid.
   with par_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) select
      uops_generated <=
         1 when RET_DAT_ADDR, --***If you wish the cmd_queue to generate and issue all commands that are inherant in a ret_dat command, change the literal to 6 
--         0 when STATUS_ADDR,  --***If you wish the cmd_queue to generate and issue all commands that are inherant in a status command, change the literal to 5
         1 when others; -- all other m-ops generate one u-op

   num_uops      <= uops_generated;
   data_size_int <= conv_integer(data_size_i);
   size_uops     <= num_uops * (CQ_NUM_CMD_HEADER_WORDS + data_size_int);
   mop_rdy <= mop_rdy_i;
   new_card_addr     <= card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);

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

           if(par_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) = RET_DAT_ADDR) then
               case current_par_id(BB_PARAMETER_ID_WIDTH-1 downto 0) is
                  when NULL_ADDR       => new_par_id_mux_sel <= RET_DAT_ADDR;
                  when RET_DAT_ADDR    => new_par_id_mux_sel <= PSC_STATUS_ADDR;
                  when PSC_STATUS_ADDR => new_par_id_mux_sel <= BIT_STATUS_ADDR;
                  when BIT_STATUS_ADDR => new_par_id_mux_sel <= FPGA_TEMP_ADDR;
                  when FPGA_TEMP_ADDR  => new_par_id_mux_sel <= CARD_TEMP_ADDR;
                  when CARD_TEMP_ADDR  => new_par_id_mux_sel <= CYC_OO_SYC_ADDR;
                  when CYC_OO_SYC_ADDR => new_par_id_mux_sel <= PAR_ID;
                  when others          => new_par_id_mux_sel <= RECIRC;
               end case;
               
--            elsif(par_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) = STATUS_ADDR) then
--               case current_par_id(BB_PARAMETER_ID_WIDTH-1 downto 0) is
--                  when PSC_STATUS_ADDR => new_par_id_mux_sel <= BIT_STATUS_ADDR;
--                  when BIT_STATUS_ADDR => new_par_id_mux_sel <= FPGA_TEMP_ADDR;
--                  when FPGA_TEMP_ADDR  => new_par_id_mux_sel <= CARD_TEMP_ADDR;
--                  when CARD_TEMP_ADDR  => new_par_id_mux_sel <= CYC_OO_SYC_ADDR;
--                  when CYC_OO_SYC_ADDR => new_par_id_mux_sel <= PAR_ID;
--                  when others          => new_par_id_mux_sel <= RECIRC;
--               end case;

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
         current_par_id(BB_PARAMETER_ID_WIDTH-1 downto 0) <= NULL_ADDR;
         num_uops_inserted_reg                          <= 0;

      elsif clk_i'event and clk_i = '1' then
         current_par_id(BB_PARAMETER_ID_WIDTH-1 downto 0) <= new_par_id(BB_PARAMETER_ID_WIDTH-1 downto 0);
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
         par_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0)      when PAR_ID, --0xEE
         current_par_id                                  when RECIRC, --0xEF
         current_par_id                                  when others;

   -- Send FSM:
   send_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_send_state <= LOAD;
         send_ptr <= ADDR_ZERO;
      elsif(clk_i'event and clk_i = '1') then
         present_send_state <= next_send_state;
         
         if(update_prev_state = '1') then
            previous_send_state <= present_send_state;
         end if;
         
         if(send_ptr_mux_sel = "000") then
            send_ptr <= send_ptr;
         elsif(send_ptr_mux_sel = "001") then
            send_ptr <= send_ptr + 1;
         elsif(send_ptr_mux_sel = "010") then
            send_ptr <= send_ptr + CQ_NUM_CMD_HEADER_WORDS + send_data_size;
         elsif(send_ptr_mux_sel = "011") then
            send_ptr <= send_ptr + 1 + NUM_NON_BB_CMD_HEADER_WORDS;
         elsif(send_ptr_mux_sel = "100") then
            send_ptr <= ADDR_ZERO;
         else
            send_ptr <= send_ptr;
         end if;
         
      end if;
   end process send_state_FF;

   -- issue_sync and timeout_sync need to be assigned continuously because they don't seem to update correctly inside the FSM
   -- There's something fishy about this.  
   -- The trade off with continuous assignement is that sometimes the assignment will be invalid, while send pointer is pointing at the first word of a packet
   -- That's ok, though.  I only used issue_sync and timeout_sync when they're valid.
   issue_sync       <= qa_sig(QUEUE_WIDTH-1 downto ISSUE_SYNC_END);
   
   -- timeout_sync was removed because the timeout length for all commands was fixed to 1 sync period, thus timeout_sync can be reomved from the queue, and the space used to provide more resolution for issue_sync
   timeout_sync     <= issue_sync + TIMEOUT_LEN;
   
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

   send_state_NS: process(present_send_state, send_ptr, free_ptr, uop_send_expired, 
                          issue_sync, timeout_sync, sync_count_slv, previous_send_state, 
                          send_data_size, uop_data_count, lvds_tx_busy, send_cmd_code, send_data_size_int, bit_ctr_count)
   begin
      next_send_state <= present_send_state;
      case present_send_state is
         
         when LOAD =>
            -- If there is a u-op waiting to be issued and if this FSM has not been frozen by the retire FSM, then send it or skip it.
            if(send_ptr /= free_ptr) then
               if(uop_send_expired = '1') then
                  -- If the u-op has expired, it is still issued.  This may have to change
                  --next_send_state <= NEXT_UOP;
                  next_send_state <= BUFFER_CMD_PARAM;
               elsif(issue_sync < timeout_sync) then
                  -- Determine whether the current sync period is between the issue sync and the timeout sync.  If so, the u-op should be issued.
                  if(sync_count_slv >= issue_sync and sync_count_slv < timeout_sync) then
                     next_send_state <= BUFFER_CMD_PARAM;
                  else
                     next_send_state <= LOAD;
                  end if;
               -- The timeout_sync can have wrapped with respect to the issue_sync
               elsif(issue_sync > timeout_sync) then
                  if(sync_count_slv >= issue_sync or sync_count_slv < timeout_sync) then
                     next_send_state <= BUFFER_CMD_PARAM;
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
         
         when BUFFER_CMD_PARAM =>
            next_send_state <= BRANCH;
            
         when BRANCH =>
            if(send_cmd_code = STOP or send_cmd_code = START) then
               next_send_state <= NEXT_UOP;
            elsif(lvds_tx_busy = '0') then
               next_send_state <= HEADER_A;
            else
               next_send_state <= BRANCH;
            end if;
         
         when HEADER_A =>
            next_send_state <= PAUSE;
         
         when HEADER_B =>
            next_send_state <= PAUSE;
         
         when HEADER_C =>
            next_send_state <= PAUSE;
         
         when HEADER_D =>
            next_send_state <= PAUSE;
         
         when DATA =>
            next_send_state <= PAUSE;
         
         when MORE_DATA =>
            next_send_state <= PAUSE;
         
         when CHECKSUM =>
            next_send_state <= PAUSE;
         
         when PAUSE =>
            -- No need to check the crc_done line because it will always be done before cmd_tx_done
            if(lvds_tx_busy = '0' and bit_ctr_count = CHECKSUM_WORD_WIDTH) then-- and crc_done = '1') then            
               if(previous_send_state = HEADER_A) then
                  next_send_state <= HEADER_B;
               elsif(previous_send_state = HEADER_B) then
                  if(send_data_size_int = 0 or send_cmd_code = READ_BLOCK) then
                     next_send_state <= CHECKSUM;
                  else
                     next_send_state <= DATA;
                  end if;
               elsif(previous_send_state = DATA) then
                  if(uop_data_count < send_data_size) then
                     next_send_state <= MORE_DATA;
                  else
                     next_send_state <= CHECKSUM;
                  end if;
               elsif(previous_send_state = MORE_DATA) then
                  if(uop_data_count < send_data_size) then
                     next_send_state <= DATA;
                  else
                     next_send_state <= CHECKSUM;
                  end if;
               elsif(previous_send_state = CHECKSUM) then
                  next_send_state <= LOAD;
               end if;
            end if;
         
         when NEXT_UOP =>
            -- Skip to the next u-op
            next_send_state <= LOAD;
         
         when others =>
            next_send_state <= LOAD;
      end case;
   end process;

   rdaddress_a_sig <= send_ptr;
   send_data_size_int <= conv_integer(send_data_size);
   
   send_data_size_reg : reg
      generic map(
         WIDTH      => QUEUE_ADDR_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => send_data_size_en,
         reg_i      => qa_sig(DATA_SIZE_END+QUEUE_ADDR_WIDTH-1 downto DATA_SIZE_END), 
         reg_o      => send_data_size
      );

   send_cmd_code_reg : reg
      generic map(
         WIDTH => BB_COMMAND_TYPE_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => send_cmd_code_en,
         reg_i      => qa_sig(ISSUE_SYNC_END-1 downto COMMAND_TYPE_END),
         reg_o      => send_cmd_code
      );

   send_state_out: process(present_send_state, bit_ctr_count, send_cmd_code) 
   begin
      -- defaults
      crc_num_bits_mux_sel     <= "00";  
      crc_clr                  <= '0';
      bit_ctr_load             <= '0';
      bit_ctr_ena              <= '0';
      lvds_tx_rdy              <= '0';
      send_ptr_mux_sel         <= "000"; 
      uop_data_count_mux_sel   <= "00";  
      cmd_tx_dat_mux_sel       <= "000"; 
      sh_reg_parallel_mux_sel  <= "00";  
      send_data_size_en        <= '0';
      send_cmd_code_en         <= '0';
      update_prev_state        <= '0';
   
      case present_send_state is
         when LOAD =>            
            crc_clr                  <= '1';

            if(bit_ctr_count < CHECKSUM_WORD_WIDTH) then
               bit_ctr_ena           <= '1';
            end if;
            
            crc_num_bits_mux_sel     <= "11";
            uop_data_count_mux_sel   <= "11";  
            cmd_tx_dat_mux_sel       <= "100";  
            update_prev_state        <= '1';
         
         when BUFFER_CMD_PARAM =>
            send_cmd_code_en         <= '1';
            send_data_size_en        <= '1';

         when BRANCH =>

         when HEADER_A =>
            lvds_tx_rdy              <= '1';
            bit_ctr_ena              <= '1';
            bit_ctr_load             <= '1';            
            
            if(send_cmd_code = READ_BLOCK) then
               crc_num_bits_mux_sel     <= "10";
            else
               crc_num_bits_mux_sel     <= "01";
            end if;
            
            uop_data_count_mux_sel   <= "11";  
            cmd_tx_dat_mux_sel       <= "001"; 
            sh_reg_parallel_mux_sel  <= "01";  
            update_prev_state        <= '1';
            send_ptr_mux_sel         <= "001"; 

         when HEADER_B =>
            lvds_tx_rdy              <= '1';
            bit_ctr_ena              <= '1';
            bit_ctr_load             <= '1';
            uop_data_count_mux_sel   <= "11";  
            cmd_tx_dat_mux_sel       <= "010"; 
            sh_reg_parallel_mux_sel  <= "10";  
            update_prev_state        <= '1';
            send_ptr_mux_sel         <= "011"; 
        
         when DATA =>
            lvds_tx_rdy              <= '1';
            bit_ctr_ena              <= '1';
            bit_ctr_load             <= '1';
            uop_data_count_mux_sel   <= "01";  
            cmd_tx_dat_mux_sel       <= "010"; 
            sh_reg_parallel_mux_sel  <= "10";  
            update_prev_state        <= '1';
            send_ptr_mux_sel      <= "001";
            
         when MORE_DATA =>
            lvds_tx_rdy              <= '1';
            bit_ctr_ena              <= '1';
            bit_ctr_load             <= '1';
            uop_data_count_mux_sel   <= "01";  
            cmd_tx_dat_mux_sel       <= "010"; 
            sh_reg_parallel_mux_sel  <= "10";  
            update_prev_state        <= '1';
            send_ptr_mux_sel         <= "001"; 
         
         when CHECKSUM =>
            lvds_tx_rdy              <= '1';
            crc_num_bits_mux_sel     <= "11";
            cmd_tx_dat_mux_sel       <= "011"; 
            update_prev_state        <= '1';
         
         when PAUSE =>
            bit_ctr_ena              <= '1';
            update_prev_state        <= '0';
            
         when NEXT_UOP =>
            crc_clr                  <= '1';
            crc_num_bits_mux_sel     <= "11";
            cmd_tx_dat_mux_sel       <= "100"; 
            update_prev_state        <= '1';
            send_ptr_mux_sel         <= "010"; 
         
         when others =>
            crc_clr                  <= '1';
            crc_num_bits_mux_sel     <= "11";
            uop_data_count_mux_sel   <= "11";  
            cmd_tx_dat_mux_sel       <= "100"; 
            update_prev_state        <= '0';

      end case;
   end process;

------------------------------------------------------------------------
--
-- recirculation muxes/ routing muxes
--
------------------------------------------------------------------------ 

   bb_cmd_code <= WRITE_CMD when 
      (send_cmd_code = WRITE_BLOCK) or 
      (send_cmd_code = RESET) or 
      (send_cmd_code = START) or 
      (send_cmd_code = STOP) else READ_CMD;  -- READ_CMD = READ_BLOCK or DATA
   
   with sh_reg_parallel_mux_sel select sh_reg_parallel_i <= 
      (others=>'0')                                                   when "00",
      BB_PREAMBLE & bb_cmd_code & qa_sig(COMMAND_TYPE_END-1 downto 0) when "01",
      qa_sig(QUEUE_WIDTH-1 downto 0)                                  when others; --"10",      

   with uop_data_count_mux_sel select uop_data_count <=
      uop_data_count_reg     when "00",
      uop_data_count_reg + 1 when "01",
      (others=>'0')          when others;
 
   with crc_num_bits_mux_sel select crc_num_bits <=
      crc_num_bits_reg                                            when "00",
      ((BB_NUM_CMD_HEADER_WORDS + send_data_size_int)*QUEUE_WIDTH) when "01",
      (BB_NUM_CMD_HEADER_WORDS*QUEUE_WIDTH)                       when "10",
      0                                                           when others;
      
   with cmd_tx_dat_mux_sel select cmd_tx_dat <=
      cmd_tx_dat_reg                                                  when "000",
      BB_PREAMBLE & bb_cmd_code & qa_sig(COMMAND_TYPE_END-1 downto 0) when "001",
      qa_sig(QUEUE_WIDTH-1 downto 0)                                  when "010",
      crc_reg                                                         when "011",
      (others=>'0')                                                   when others;
      
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         crc_num_bits_reg  <= 0;
         cmd_tx_dat_reg    <= (others=>'0');
         uop_data_count_reg<= (others=>'0');
      elsif clk_i'event and clk_i = '1' then
         crc_num_bits_reg  <= crc_num_bits;
         cmd_tx_dat_reg    <= cmd_tx_dat; 
         uop_data_count_reg<= uop_data_count;
      end if;
   end process;

   sync_count_slv    <= sync_num_i;
   -- This line was used when the sync number was generate internally to this block.
   -- Now it is generated externally, but I've kept this line to demonstrate the proper method for converting int=>std_logic_vector
   --sync_count_slv    <= std_logic_vector(conv_unsigned(sync_count_int, 8));
   
   -- CRC logic
   crc_ena           <= '1' when bit_ctr_count < 32 or crc_clr = '1' else '0';   
   crc_data          <= sh_reg_serial_o;
   crc_reg           <= crc_checksum when crc_done = '1' else crc_reg;

end behav;

-- Think about using the free_ptr index to tag the u-op sequence number in the queue.

-- The send FSM needs a way of notifying the retire fsm wheter a u-op has been skipped or not
-- NEXT_UOP in send_states should tag the uop with a special code so that the retire fsm can recognize that it was skipped.
-- I need to insert a code either in the start sync, end sync or data size field.  
-- At this point, I think that I'll use the data size field, because there are definate limits to the size that a packet will be.
-- I can't add a new state in the send state machine that would alter the data field, because you can only read from the qa_sig data port.