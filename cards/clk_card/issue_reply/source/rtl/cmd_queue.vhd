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
-- $Id: cmd_queue.vhd,v 1.90 2006/05/29 23:11:00 bburger Exp $
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
-- Revision 1.90  2006/05/29 23:11:00  bburger
-- Bryce: Removed unused signals to simplify code and remove warnings from Quartus II
--
-- Revision 1.89  2006/03/09 00:55:07  bburger
-- Bryce:  Added an issue_sync_o signal to the interface so that the reply_queue can include this information in data headers
--
-- Revision 1.88  2006/02/02 00:26:24  mandana
-- added range to integer bit_ctr_coun
--
-- Revision 1.87  2006/01/16 18:07:33  bburger
-- Bryce:  Brand new version of the cmd_queue.  It only queue's up a single command at a time.
--
-- Revision 1.86  2005/11/15 03:17:22  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
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
      debug_o         : out std_logic_vector(31 downto 0);
      timer_trigger_o : out std_logic;

      -- reply_queue interface
      uop_rdy_o       : out std_logic; 
      uop_ack_i       : in std_logic; 
      card_addr_o     : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      par_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_o     : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      cmd_type_o      : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);
      -- indicates a STOP command was recieved
      cmd_stop_o      : out std_logic;                                          
      -- indicates the last frame of data for a ret_dat command
      last_frame_o    : out std_logic;                                          
      frame_seq_num_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_o  : out std_logic;
      issue_sync_o    : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- cmd_translator interface
      card_addr_i     : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      par_id_i        : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      data_size_i     : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0); 
      data_i          : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  
      data_clk_i      : in std_logic; 
      issue_sync_i    : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      mop_rdy_i       : in std_logic;
      mop_ack_o       : out std_logic; 
      cmd_type_i      : in std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
      cmd_stop_i      : in std_logic;                                          
      last_frame_i    : in std_logic;                                          
      frame_seq_num_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_i  : in std_logic;

      -- lvds_tx interface
      tx_o            : out std_logic;  

      -- frame_timing interface
      sync_num_i      : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Clock lines
      clk_i           : in std_logic; 
      rst_i           : in std_logic  
   );
end cmd_queue;

architecture behav of cmd_queue is

constant ADDR_ZERO          : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0)   := (others => '0');
constant ADDR_FULL_SCALE    : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0)   := (others => '1');
constant TIMEOUT_LEN        : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0)   := x"00000001";  -- Defines the window during which an instruction can be issued
constant HIGH               : std_logic := '1';
constant LOW                : std_logic := '0';
constant INT_ZERO           : integer   :=  0;

-----------------------------------------------------
-- cmd_queue signals (_t means temporary)
-----------------------------------------------------
-- Register Signals
signal card_addr            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); -- The card address of the m-op
signal par_id               : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); -- The parameter id of the m-op
signal data_size            : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
signal data_size_int_t      : integer;
signal issue_sync           : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
signal cmd_type             : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
signal bit_status           : std_logic_vector(2 downto 0);
signal bit_status_i         : std_logic_vector(2 downto 0);
signal frame_seq_num        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal reg_en               : std_logic;

-- Data Word Counter
signal data_count_clr       : std_logic;
signal data_count_incr      : std_logic;
signal data_count           : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

-- Data Queue I/O
signal wren_sig             : std_logic;
signal qa_sig               : std_logic_vector(QUEUE_WIDTH-1 downto 0);
--signal qb_sig               : std_logic_vector(QUEUE_WIDTH-1 downto 0);

-- LVDS Tx Signals
signal lvds_tx_word         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal lvds_tx_rdy          : std_logic;
signal lvds_tx_busy         : std_logic;

-- Bit Counter signals
signal bit_ctr_count        : integer range 0 to QUEUE_WIDTH;
signal bit_ctr_ena          : std_logic; -- enables the counter which controls the enable line to the CRC block.  The counter should only be functional when there is a to calculate.
signal bit_ctr_load         : std_logic; --Not part of the interface to the crc block; enables sh_reg and bit_ctr.

-- CRC signals:
signal crc_clr              : std_logic;
signal crc_ena              : std_logic;
signal crc_num_bits         : integer;
signal crc_done             : std_logic;
--signal crc_valid            : std_logic;
signal crc_checksum         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal crc_reg              : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

-- Shift Register signals:
signal sh_reg_serial_o      : std_logic;
--signal sh_reg_parallel_o    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); --Dummy signal

-- Miscellaneous Signals
signal uop_send_expired     : std_logic;
signal timeout_sync         : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
signal update_prev_state    : std_logic;
signal timer_clr            : std_logic;
signal timer_count          : integer;

-- Control FSM
type states is (IDLE, STORE_CMD_PARAM, IS_THERE_DATA, STROBE_DETECT, LATCH_DATA, DONE_STORE, WAIT_TO_ISSUE, 
   WORD_PAUSE, WORD_RDY, ISSUE, HEADER_A, HEADER_B, SOME_DATA, MORE_DATA, DATA_WORD, CHECKSUM, CMD_ISSUED, 
   WAIT_TO_RETIRE, RETIRE);
signal present_state  : states;
signal next_state     : states;
signal previous_state : states;


begin

   -----------------------------------------------------
   -- Combinatorial Logic
   -----------------------------------------------------   
   uop_send_expired <= '1' when (sync_num_i = timeout_sync) else '0';
   timeout_sync     <= issue_sync + TIMEOUT_LEN;
   
   
   -- For hardware integration with the logic analyzer
   debug_o(31 downto 0)  <=  lvds_tx_word(31 downto 1) & lvds_tx_busy;      
   timer_clr             <= '1' when present_state = IDLE;
   
   -----------------------------------------------------
   -- Outputs
   -----------------------------------------------------
   card_addr_o     <= card_addr;
   par_id_o        <= par_id;
   data_size_o     <= data_size;
   cmd_type_o      <= cmd_type;
   last_frame_o    <= bit_status(0);
   cmd_stop_o      <= bit_status(1);
   internal_cmd_o  <= bit_status(2);
   frame_seq_num_o <= frame_seq_num;

   -----------------------------------------------------
   -- Registers
   -----------------------------------------------------
   card_addr_reg: reg
      generic map(
         WIDTH      => BB_CARD_ADDRESS_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => card_addr_i,
         reg_o      => card_addr
      );

   par_id_reg: reg
      generic map(
         WIDTH      => BB_PARAMETER_ID_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => par_id_i,
         reg_o      => par_id
      );

   data_size_reg_t: reg
      generic map(
         WIDTH      => BB_DATA_SIZE_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => data_size_i,
         reg_o      => data_size
      );

   issue_sync_o <= issue_sync;
   issue_sync_reg: reg
      generic map(
         WIDTH      => SYNC_NUM_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => issue_sync_i,
         reg_o      => issue_sync
      );

   cmd_type_reg: reg
      generic map(
         WIDTH      => BB_COMMAND_TYPE_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => cmd_type_i,
         reg_o      => cmd_type
      );

   bit_status_i <= internal_cmd_i & cmd_stop_i & last_frame_i;
   bit_status_reg: reg
      generic map(
         WIDTH      => 3
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => bit_status_i,
         reg_o      => bit_status
      );

   frame_seq_num_reg: reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => frame_seq_num_i,
         reg_o      => frame_seq_num
      );

   -----------------------------------------------------
   -- Buffers and RAM
   -----------------------------------------------------
   cmd_queue_ram40_inst: cmd_queue_tpram
      port map(
         data        => data_i,
         wraddress   => data_count(QUEUE_ADDR_WIDTH-1 downto 0),
         rdaddress_a => data_count(QUEUE_ADDR_WIDTH-1 downto 0),
         rdaddress_b => data_count(QUEUE_ADDR_WIDTH-1 downto 0),
         wren        => wren_sig,
         clock       => clk_i,  
         qa          => qa_sig,          
         qb          => open --qb_sig -- qb_sig data is not used by the FSM
      );

   -----------------------------------------------------
   -- LVDS interface to the Bus Backplane
   -----------------------------------------------------
   cmd_tx2: lvds_tx
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         dat_i      => lvds_tx_word,
         rdy_i      => lvds_tx_rdy,
         busy_o     => lvds_tx_busy,
         lvds_o     => tx_o
      );
  
   -----------------------------------------------------
   -- CRC control
   -----------------------------------------------------
   cmd_crc: serial_crc
      generic map(
         POLY_WIDTH  => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         clr_i      => crc_clr,
         ena_i      => crc_ena,
         data_i     => sh_reg_serial_o,
         num_bits_i => crc_num_bits,
         poly_i     => "00000100110000010001110110110111",         
         done_o     => crc_done,
         valid_o    => open, --crc_valid, 
         checksum_o => crc_checksum 
      );
      
   sh_reg: shift_reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )   
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => HIGH,       
         load_i     => bit_ctr_load,      
         clr_i      => LOW,    
         shr_i      => HIGH,        
         serial_i   => LOW, 
         serial_o   => sh_reg_serial_o,  
         parallel_i => lvds_tx_word, 
         parallel_o => open --sh_reg_parallel_o
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
   
   -----------------------------------------------------
   -- Timer
   -----------------------------------------------------
   -- This trigger is way over the time needed for a ret_dat command - to see if there are bottle necks on the MCE side of things
   timer_trigger_o <= '1' when timer_count >= 1200 else '0';
   trigger_timer : us_timer
      port map(
         clk           => clk_i,
         timer_reset_i => timer_clr,
         timer_count_o => timer_count
      );
   
   -----------------------------------------------------
   -- New cmd_queue
   -----------------------------------------------------
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      
         if(update_prev_state = '1') then
            previous_state <= present_state;
         end if;      
         
      end if;
   end process;
   
   state_NS: process(present_state, mop_rdy_i, data_size, data_clk_i, data_count, cmd_type,
   uop_send_expired, issue_sync, timeout_sync, sync_num_i, lvds_tx_busy, bit_ctr_count, previous_state,
   uop_ack_i)
   begin
      next_state <= present_state;
      case present_state is
         when IDLE =>
            if(mop_rdy_i = '1') then
               next_state <= STORE_CMD_PARAM;
            end if;
         
         --   -- command types:
         --constant WRITE_CMD         : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "1";
         --constant READ_CMD          : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "0";

         
         --constant WRITE_BLOCK : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "000";
         --constant READ_BLOCK  : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "001";
         --constant START       : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "010";
         --constant STOP        : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "011";
         --constant RESET       : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "100";
         --constant DATA        : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "101";
      
         -----------------------------------------------------
         -- Store Command
         -----------------------------------------------------
         when STORE_CMD_PARAM =>
            next_state <= IS_THERE_DATA;

         when IS_THERE_DATA =>
            if(cmd_type = READ_CMD or data_size = 0) then
               next_state <= DONE_STORE;
            else
               next_state <= STROBE_DETECT;
            end if;
         
         when STROBE_DETECT =>
            if(data_clk_i = '1') then
               next_state <= LATCH_DATA;
            else
               next_state <= STROBE_DETECT;
            end if;
            
         when LATCH_DATA =>
            if(data_count < data_size) then
               next_state <= STROBE_DETECT;
            else
               next_state <= DONE_STORE;
            end if;

         when DONE_STORE =>
            next_state <= WAIT_TO_ISSUE;

         -----------------------------------------------------
         -- Issue Command
         -----------------------------------------------------
         when WAIT_TO_ISSUE =>
            if(par_id /= RET_DAT_ADDR) then
               next_state <= HEADER_A;
-- If a data command has timed out, then a flag must be included in the header
-- This is to indicate that the timing has jitter..
            elsif(uop_send_expired = '1') then
               -- If the u-op has expired, it is still issued.  This may have to change
               -- uops typically will not expire while waiting in the cmd_queue, because the the command queue can issue uops faster than mops will be received from the cmd_translator (assuming the internal commanding rate is reasonable).
               --next_send_state <= NEXT_UOP;
               next_state <= HEADER_A;
            -- Determine whether the current sync period is between the issue sync and the timeout sync.  If so, the u-op should be issued.
            elsif(issue_sync < timeout_sync) then
               if(sync_num_i >= issue_sync and sync_num_i < timeout_sync) then
                  next_state <= HEADER_A;
               end if;
            -- The timeout_sync can have wrapped with respect to the issue_sync
            elsif(issue_sync > timeout_sync) then
               if(sync_num_i >= issue_sync or sync_num_i < timeout_sync) then
                  next_state <= HEADER_A;
               end if;
            else
               -- If the u-op is still good, but isn't supposed to be issued yet, stay in LOAD
               next_state <= WAIT_TO_ISSUE;
            end if;
            
         when ISSUE =>
            -- No need to check the crc_done line because it will always be done before cmd_tx_done
            if(lvds_tx_busy = '0' and bit_ctr_count = PACKET_WORD_WIDTH) then            
               if(previous_state = HEADER_A) then
                  next_state <= HEADER_B;
               elsif(previous_state = HEADER_B) then
                  if(cmd_type = READ_CMD or data_size = 0) then
                     next_state <= CHECKSUM;
                  else
                     next_state <= DATA_WORD;
                  end if;
               elsif(previous_state = DATA_WORD) then
                  if(data_count < data_size) then
                     next_state <= DATA_WORD;
                  else
                     next_state <= CHECKSUM;
                  end if;               
               elsif(previous_state = CHECKSUM) then
                  next_state <= CMD_ISSUED;
               end if;
            end if;
            
         when HEADER_A =>
            next_state <= WORD_PAUSE;
        
         when HEADER_B =>
            next_state <= WORD_PAUSE;
         
         when DATA_WORD =>
            next_state <= WORD_PAUSE;
         
         when CHECKSUM =>
            next_state <= WORD_PAUSE;
            
         when WORD_PAUSE =>
            next_state <= WORD_RDY;

         when WORD_RDY =>
            next_state <= ISSUE;
         
         when CMD_ISSUED =>
            next_state <= WAIT_TO_RETIRE;

         -----------------------------------------------------
         -- Retire Command
         -----------------------------------------------------
         when WAIT_TO_RETIRE =>
            if(uop_ack_i = '1') then
               next_state <= RETIRE;
            end if;
         
         when RETIRE =>
            next_state <= IDLE;
         
         when others =>
            next_state <= IDLE;
      end case;
   end process;

--   bb_cmd_code <= WRITE_CMD when 
--      (cmd_type = WRITE_BLOCK) or 
--      (cmd_type = RESET) or 
--      (cmd_type = GO) or 
--      (cmd_type = STOP) else READ_CMD;  -- READ_CMD = READ_BLOCK or DATA

   data_size_int_t <= conv_integer(data_size);
   misc_registers: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         lvds_tx_word    <= (others => '0');
         crc_num_bits    <= 0;
         crc_reg         <= (others => '0');
         
      elsif(clk_i'event and clk_i = '1') then
         
         if(crc_done = '1') then
            crc_reg <= crc_checksum;
         else
            crc_reg <= crc_reg;
         end if;
         
         if(present_state = WAIT_TO_ISSUE) then
            if(cmd_type = READ_CMD) then
               crc_num_bits <= (BB_NUM_CMD_HEADER_WORDS * QUEUE_WIDTH);
            else
               crc_num_bits <= ((BB_NUM_CMD_HEADER_WORDS + data_size_int_t) * QUEUE_WIDTH);
            end if;
         else
            crc_num_bits <= crc_num_bits;
         end if;
         
         if(present_state = HEADER_A) then
            lvds_tx_word <= BB_PREAMBLE & cmd_type & data_size;
         elsif(present_state = HEADER_B) then
            lvds_tx_word <= card_addr & par_id & x"0000";
         elsif(present_state = DATA_WORD) then
            lvds_tx_word <= qa_sig;
         elsif(present_state = CHECKSUM) then
            lvds_tx_word <= crc_reg;
         else
            lvds_tx_word <= lvds_tx_word;
         end if;
         
      end if;
   end process;

   data_counter: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data_count    <= (others =>'0');
      elsif(clk_i'event and clk_i = '1') then
         if(data_count_clr = '1') then
            data_count <= (others => '0');
         elsif(data_count_incr = '1') then
            data_count <= data_count + 1;
         else
            data_count <= data_count;
         end if;
      end if;
   end process;

   state_out: process(present_state, data_clk_i, data_size, bit_ctr_count, previous_state)
   begin   
      --defaults
      reg_en               <= '0';
      data_count_clr       <= '0';
      data_count_incr      <= '0';
      mop_ack_o            <= '0';
      wren_sig             <= '0';
      update_prev_state    <= '0';
      lvds_tx_rdy          <= '0';
      bit_ctr_ena          <= '0';
      bit_ctr_load         <= '0';
      crc_clr              <= '0';
      uop_rdy_o            <= '0';
      crc_ena              <= '0';
      
      case present_state is
         when IDLE =>
            data_count_clr       <= '1';
            crc_clr              <= '1';
            crc_ena              <= '1';
            update_prev_state    <= '1';
         
         -----------------------------------------------------
         -- Store Command
         -----------------------------------------------------
         when STORE_CMD_PARAM =>
            reg_en               <= '1';
         
         when IS_THERE_DATA =>
            -- Asserting mop_ack_o causes cmd_translator to begin passing data through to cmd_queue.
            if(data_size /= 0) then
               mop_ack_o         <= '1';
            end if;
         
         when STROBE_DETECT =>
            if(data_clk_i = '1') then
               wren_sig          <= '1';
               data_count_incr   <= '1';
            end if;
         
         when LATCH_DATA =>
            
         when DONE_STORE =>
            -- If there is no data with the m-op, then asserting mop_ack_o in the IS_THERE_DATA state would be too soon
            -- In this case, by delaying its assertion until DONE_STORE, we ensure that the cmd_translator doesn't try to insert the next m_op too quickly.
            if(data_size = 0) then
               mop_ack_o         <= '1';
            end if;
         
         -----------------------------------------------------
         -- Issue Command
         -----------------------------------------------------
         when WAIT_TO_ISSUE =>
            data_count_clr       <= '1';

         when ISSUE =>
            if(previous_state /= CHECKSUM and bit_ctr_count < PACKET_WORD_WIDTH) then
               bit_ctr_ena          <= '1';
               crc_ena              <= '1';
            end if;
         
         when HEADER_A =>
            update_prev_state    <= '1';

         when HEADER_B =>
            update_prev_state    <= '1';

         when DATA_WORD =>
            data_count_incr      <= '1';
            update_prev_state    <= '1';

         when CHECKSUM =>
            update_prev_state    <= '1';

         when WORD_PAUSE =>
            if(previous_state /= CHECKSUM) then
               bit_ctr_ena       <= '1';
               bit_ctr_load      <= '1';
            end if;

         when WORD_RDY =>
            lvds_tx_rdy          <= '1';
            if(previous_state /= CHECKSUM) then
               bit_ctr_ena       <= '1';
               crc_ena           <= '1';
            end if;

         when CMD_ISSUED =>
            uop_rdy_o            <= '1';

         -----------------------------------------------------
         -- Retire Command
         -----------------------------------------------------
         when WAIT_TO_RETIRE =>  
            null;
         
         when RETIRE =>          
            null;
         
         when others =>          
            null;
      end case;
   end process;

end behav;
