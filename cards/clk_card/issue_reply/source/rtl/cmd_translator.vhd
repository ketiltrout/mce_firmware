-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

--
--
-- <revision control keyword substitutions e.g. $Id: cmd_translator.vhd,v 1.72 2012-03-27 23:34:42 mandana Exp $>
--
-- Project:       SCUBA-2
-- Author:        Jonathan Jacob, re-vamped by Bryce Burger
--
-- Organisation:  UBC
--
-- Description:  This module has two main parts:
-- 1. Translates incoming fibre commands and interfaces with the fibre_rx block
-- 2. runs the command scheduler FSM that interfaces with the Command Queue block
-- The command scheduler schedules: 
-- a) simple (non-ret_dat) commands arriving over the fibre, 
-- b) data-acquisition(ret_dat and stop) commands arriving over the fibre 
-- c) internal housekeeping commands (internal_cmd_mode = 1) 
--    (4 housekeeping commands so far: fpga_temp, card_temp, psc_status, box_temp)
-- d) internal ramp/awg commands (internal_cmd_mode = 2)
-- Note that when running internal ramp/awg, housekeeping commands are not issued
--
-- Revision history:
-- See CVS.
--
-----------------------------------------------------------------------------

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
use work.frame_timing_pack.all;

-- Call Parent library
use work.clk_card_pack.all;
use work.issue_reply_pack.all;


entity cmd_translator is
   port(
      -- global inputs
      rst_i                 : in  std_logic;
      clk_i                 : in  std_logic;

      -- inputs from fibre_rx
      card_addr_i           : in  std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies the target card for the incoming command
      cmd_code_i            : in  std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);   
      cmd_data_i            : in  std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);         
      cmd_rdy_i             : in  std_logic;                                              -- indicates the fibre_rx outputs are valid
      data_clk_i            : in  std_logic;                                              -- used to clock the data across
      num_data_i            : in  std_logic_vector(FIBRE_DATA_SIZE_WIDTH-1 downto 0);     -- number of 32bit data words to be clocked across
      param_id_i            : in  std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- the parameter id of the command to be issued

      -- output to fibre_rx
      ack_o                 : out std_logic;                                                     

      -- ret_dat_wbs interface:
      start_seq_num_i       : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      stop_seq_num_i        : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      data_rate_i           : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      dv_mode_i             : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i         : in std_logic;
      awg_dat_i             : in std_logic_vector(AWG_DAT_WIDTH-1 downto 0);
      awg_addr_i            : in std_logic_vector(AWG_ADDR_WIDTH-1 downto 0);
      awg_addr_incr_o       : out std_logic;
      internal_cmd_mode_i   : in std_logic_vector(INTERNAL_CMD_MODE_WIDTH-1 downto 0);	  -- indicates one of NUM_INTERNAL_CMD_MODES
      step_period_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- refresh rate for ramp/awg mode
      step_minimum_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- minimum ramp value for ramp mode 
      step_size_i           : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- step increment value for the ramp-mode
      step_maximum_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- maximum ramp value for ramp mode
      step_param_id_i       : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- the parameter that is being ramped in ramp mode
      step_card_addr_i      : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- the target card for the ramp mode						     
      step_data_num_i       : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- number of data elements being ramped for the step_param_id_i in ramp mode
      step_phase_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- startup phase in ramp mode
      step_value_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);		  -- ramp value	for reply_q to be reported in the header
     
      -- frame_timing interface
      sync_number_i         : in  std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      sync_pulse_i          : in std_logic;

      -- cmd_queue interface
      cmd_code_o            : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      card_addr_o           : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      param_id_o            : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_o           : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      data_o                : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      data_clk_o            : out std_logic;                                              -- indicates an instruction is ready, and all the associated data is valid   
      instr_rdy_o           : out std_logic;                                             
      cmd_stop_o            : out std_logic;                                              -- indicates that a stop command is received
      last_frame_o          : out std_logic;                                              -- identifies the last frame of data
      internal_cmd_o        : out std_logic;                                              -- an internal command is being scheduled
      simple_cmd_o          : out std_logic;                                              -- a simple command is being scheduled
      num_rows_to_read_i    : in integer;
      num_cols_to_read_i    : in integer;
      override_sync_num_o   : out std_logic;
      ret_dat_in_progress_o : out std_logic;
      frame_seq_num_o       : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      frame_sync_num_o      : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- input from the cmd_queue
      ack_i                 : in std_logic;
      rdy_for_data_i        : in std_logic;
      data_timing_err_i     : in std_logic;
      busy_i                : in std_logic
   );
end cmd_translator;

architecture rtl of cmd_translator is
   -- FSM signals
   type state is (IDLE, SIMPLE, FPGA_TEMP, CARD_TEMP, PSC_STATUS, BOX_TEMP, INTERNAL_WB_PREP, INTERNAL_WB_WAIT, INTERNAL_WB, INTERNAL_WB_DATA,
      NEXT_INTERNAL_CMD, UPDATE_FOR_NEXT, PROCESSING_RET_DAT, REQ_LAST_DATA_PACKET);
   signal current_state : state;
   signal next_state    : state;

   -- For tracking ret_dat requests
   signal ret_dat_req         : std_logic;                               -- request to issue a ret_dat command
   signal ret_dat_stop_req    : std_logic;                               -- request to issue a stop command
   signal ret_dat_ack         : std_logic;                               -- acknowledge a ret_dat command completion!
   
   -- If a ret_dat command comes in during an internal command, the cmd_translator messes up in the NEXT_INTERNAL_CMD state.
   signal ret_dat_start       : std_logic;                               -- controlled by FSM to set ret_dat_in_progress
   signal ret_dat_done        : std_logic;                               -- controlled by FSM to reset ret_dat_in_progress
   signal ret_dat_in_progress : std_logic;                               -- indicates a ret_dat command is in progress

   -- For ack'ing a data run: command parameters extrated from an incoming ret_dat command
   signal f_rx_ret_dat_ack       : std_logic;
   signal f_rx_ret_dat_card_addr : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal f_rx_ret_dat_param_id  : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal f_rx_ret_dat_data      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

   -- command parameters extracted from an incoming simple command
   signal f_rx_card_addr   : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal f_rx_param_id    : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal f_rx_cmd_code    : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal f_rx_num_data    : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

   signal frame_sync_num   : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0); -- sync number that a ret_dat command is scheduled to be issued
   signal inc_sync_num     : std_logic;					  -- control signal to increment frame_sync_num by 1
   signal jump_sync_num    : std_logic;   				  -- control signal to calculate next frame_sync_num based on data rate.
   
   signal seq_num          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);  -- the frame sequence number during data process
   signal load_seq_num     : std_logic;   
   signal inc_seq_num      : std_logic;
   
   signal data_size        : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data_size_int    : integer range 0 to (2**BB_DATA_SIZE_WIDTH)-1;

   -------------------------------------------------------------------------------------------
   -- Internal command control signals
   -------------------------------------------------------------------------------------------
   constant NUM_HOUSEKEEPING_CMD_TYPES : integer := 4;
   constant FPGA_TEMPERATURE       : integer := 0;
   constant CARD_TEMPERATURE       : integer := 1;
   constant PSUC_STATUS            : integer := 2;
   constant BOX_TEMPERATURE        : integer := 3;
   
   signal internal_status_req      : std_logic;                            -- request to issue an internal housekeeping command
   signal internal_status_ack      : std_logic;                            -- ack a completed internal housekeeping command
   signal internal_wb_req          : std_logic;                            -- request to issue an internal ramp/awg command
   signal internal_wb_ack          : std_logic;                            -- ack a completed internal ramp/awg command
   
   signal next_toggle_sync         : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0); -- sync number that the next internal ramp/awg cmd is scheduled to be issued
   signal update_next_toggle_sync  : std_logic;                            -- update next_toggle_sync

   signal timer_rst                : std_logic;
   signal time_elapsed             : integer; --range 0 to HOUSEKEEPING_COMMAND_PERIOD+100; 
   signal internal_rb_id           : integer range 0 to NUM_HOUSEKEEPING_CMD_TYPES;
   signal internal_rb_ack          : std_logic;                                    -- ack for an internal command, asserted for 1 cycle after command completion

   signal ramp_value               : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal next_ramp_value          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ramp_value_reported      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ramp_value_reg_en        : std_logic;
   signal internal_cmd_mode_1d     : std_logic_vector(INTERNAL_CMD_MODE_WIDTH-1 downto 0);
   signal step_period_1d           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_phase_1d            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ret_dat_in_progress_1d   : std_logic;
   signal awg_addr                 : std_logic_vector(AWG_ADDR_WIDTH-1 downto 0);
   signal cmd_collision            : std_logic;
   signal cmd_collision_reg_en     : std_logic;

   -- For detecting changes in the internal-mode parameters
   signal cmd_mode_changing         : std_logic;
   --signal step_period_changing      : std_logic;   
   signal step_phase_changing       : std_logic;   
   signal realign_ramp2data         : std_logic;   
   
   -------------------------------------------------------------------------------------------
   -- simple command control signals
   -------------------------------------------------------------------------------------------
   signal simple_cmd_ack : std_logic;
   signal simple_cmd_req : std_logic;

begin   
   ack_o <= f_rx_ret_dat_ack or simple_cmd_ack;
   
   data_size_int          <= num_cols_to_read_i * num_rows_to_read_i;
   data_size              <= conv_std_logic_vector(data_size_int,BB_DATA_SIZE_WIDTH);
   -------------------------------------------------------------------------------------------
   -- Registers
   -------------------------------------------------------------------------------------------
   i_latch_fibre_cmd_param: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         f_rx_ret_dat_card_addr    <= (others=>'0');
         f_rx_ret_dat_param_id     <= (others=>'0');
         f_rx_ret_dat_data         <= (others=>'0');
         f_rx_card_addr            <= (others=>'0');
         f_rx_param_id             <= (others=>'0');
         f_rx_cmd_code             <= (others=>'0');
         f_rx_num_data             <= (others=>'0');      
      elsif(clk_i'event and clk_i = '1') then
         -- To properly handle simple-cmds that arrive during data run, parameters for simple and ret_dat cmds are latched seperately.
         if(cmd_rdy_i = '1') then
            if(param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) = RET_DAT_ADDR) then
               f_rx_ret_dat_card_addr <= card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);
               f_rx_ret_dat_param_id  <= param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0);
               f_rx_ret_dat_data      <= cmd_data_i;
            else
               f_rx_card_addr         <= card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);
               f_rx_param_id          <= param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0);
               f_rx_cmd_code          <= cmd_code_i;
               f_rx_num_data          <= num_data_i(BB_DATA_SIZE_WIDTH-1 downto 0);
            end if;
         end if;   
      end if;   
   end process i_latch_fibre_cmd_param;
   -------------------------------------------------------------------------------------------      
   internal_hk_cmd_index: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         internal_rb_id            <=  0;
      elsif(clk_i'event and clk_i = '1') then      
         if(internal_rb_ack = '1') then
            if (internal_rb_id < NUM_HOUSEKEEPING_CMD_TYPES-1) then
               internal_rb_id <= internal_rb_id + 1;
            else  
               internal_rb_id <= 0;
            end if;
         else
            internal_rb_id <= internal_rb_id;
         end if;
      end if;
   end process internal_hk_cmd_index;
   -------------------------------------------------------------------------------------------         
   i_seq_num_counter: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         seq_num <= (others=>'0');
      elsif(clk_i'event and clk_i = '1') then         
         if(load_seq_num = '1') then
            seq_num <= start_seq_num_i;
         elsif(inc_seq_num = '1') then
            seq_num <= seq_num + 1;
         end if;
      end if;
   end process i_seq_num_counter;  
   frame_seq_num_o      <= seq_num;   
   -------------------------------------------------------------------------------------------         
   i_frame_sync_num_counter: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         frame_sync_num  <= (others=>'0');
      elsif(clk_i'event and clk_i = '1') then      
         if(inc_sync_num = '1') then
            frame_sync_num <= sync_number_i + 1;
         elsif(jump_sync_num = '1') then
            frame_sync_num <= frame_sync_num + data_rate_i;
-- No delay is necessary here, because the reply_translator takes of delaying the reply to the PCI card
--         elsif(delay_sync_num = '1') then
--            -- delay the issue of the last data command on a STOP to give the PCI card time
--            frame_sync_num <= sync_number_i + STOP_DELAY;
         end if;         
      end if;         
   end process i_frame_sync_num_counter;
   frame_sync_num_o     <= frame_sync_num; -- when override_sync_num_o = '0' else sync_number_i;
   -------------------------------------------------------------------------------------------   
   i_track_cmd_req: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         simple_cmd_req      <= '0';
         internal_status_req <= '0';
         internal_wb_req     <= '0';
         ret_dat_req         <= '0';
         ret_dat_stop_req    <= '0';        
      elsif(clk_i'event and clk_i = '1') then
         ------------------------- 
         if(simple_cmd_ack = '1') then
            simple_cmd_req <= '0';
         elsif(cmd_rdy_i = '1') then
            if(param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) /= RET_DAT_ADDR) then
               simple_cmd_req <= '1';
            end if;
         end if;
         -------------------------
         -- internal_status_ack is asserted for two consecutive cycles to make sure that both timer and internal_status_req are cleared.
         if(internal_status_ack = '1') then
            internal_status_req  <= '0';
         elsif(internal_cmd_mode_i = INTERNAL_HOUSEKEEPING and time_elapsed >= HOUSEKEEPING_COMMAND_PERIOD) then
            internal_status_req  <= '1';
         end if;
         -------------------------
         -- Sync up internal commands with start of data acquisition (ret_dat)
         if((internal_cmd_mode_i = INTERNAL_RAMP or internal_cmd_mode_i = INTERNAL_MEM) and 
            (next_toggle_sync = sync_number_i )) then --or ret_dat_start = '1')) then
               if (sync_number_i = frame_sync_num) then
                  internal_wb_req <= '0';
               else   
                  internal_wb_req <= '1';
               end if;   
         elsif(internal_wb_ack = '1') then
            internal_wb_req <= '0';
         end if;
         -------------------------
         if(ret_dat_ack = '1') then
            -- Data run is done
            ret_dat_req <= '0';
            ret_dat_stop_req <= '0';
         elsif(cmd_rdy_i = '1') then
            if(param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) = RET_DAT_ADDR) then
               if(cmd_code_i = GO) then
                  -- ret_dat_req stays asserted for the duration of the data acquisition
                  ret_dat_req <= '1';
               else
                  -- Assume it's a stop command, and de-assert ret_dat_req, why ASSUME! why not trust cmd_stop_i from cmd_queue????
                  ret_dat_req <= '0';
                  ret_dat_stop_req <= '1';
               end if;
            end if;
         end if;                       
      end if; --clk
   end process i_track_cmd_req;  
   simple_cmd_o <= simple_cmd_req;
   -------------------------------------------------------------------------------------------      
   i_ret_dat_in_progress: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         ret_dat_in_progress <= '0';
      elsif(clk_i'event and clk_i = '1') then   
         if(ret_dat_done = '1') then
            ret_dat_in_progress <= '0';
         elsif(ret_dat_start = '1') then
            ret_dat_in_progress <= '1';
         end if;
      end if;
   end process i_ret_dat_in_progress;  
   ret_dat_in_progress_o  <= ret_dat_in_progress;
   
   -------------------------------------------------------------------------------------------
   i_regs: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         internal_cmd_mode_1d <= "00";
         step_period_1d <= (others => '0');      
         step_phase_1d <= (others => '0');
         ret_dat_in_progress_1d <= '0';
      elsif(clk_i'event and clk_i = '1') then
         internal_cmd_mode_1d <= internal_cmd_mode_i;
         step_period_1d       <= step_period_i;
         step_phase_1d        <= step_phase_i;
         ret_dat_in_progress_1d <= ret_dat_in_progress;
      end if;
   end process i_regs; 
   
   cmd_mode_changing    <= '0' when internal_cmd_mode_1d = internal_cmd_mode_i else '1';
   -- step_period_changing <= '0' when step_period_1d = step_period_i else '1';
   step_phase_changing  <= '0' when step_phase_1d = step_phase_i else '1';
   realign_ramp2data    <= ret_dat_in_progress and not(ret_dat_in_progress_1d);   
   -------------------------------------------------------------------------------------------      
   i_ramp_awg_advance: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         next_toggle_sync <= (others => '0');
         ramp_value       <= (others => '0');
         next_ramp_value  <= (others => '0');
         ramp_value_reported <= (others => '0');
         awg_addr         <= (others => '0');      
         cmd_collision    <= '0';
      elsif(clk_i'event and clk_i = '1') then    
      
         -- when there is a ret_dat/internal_cmd collision, we should still advance the ramp_value
         if (frame_sync_num = next_toggle_sync and next_toggle_sync = sync_number_i) then
            cmd_collision <= '1';   
         elsif cmd_collision_reg_en = '1' then
            cmd_collision <= '0';
         else    
            cmd_collision <= cmd_collision;   
         end if;   
         ----- next_toggle_sync logic --------
         if (internal_cmd_mode_i = INTERNAL_RAMP or internal_cmd_mode_i = INTERNAL_MEM) then
            if (step_phase_changing = '1' or cmd_mode_changing = '1' or realign_ramp2data = '1') then
               next_toggle_sync <= sync_number_i + 2 + step_phase_i; 
            elsif(update_next_toggle_sync = '1' or sync_number_i = next_toggle_sync) then               
               next_toggle_sync <= sync_number_i + step_period_i;
            end if;   
         end if;
         
         ----- ramp_value reported in header -----
         -- only refresh when it's applied 
         if (ramp_value_reg_en = '1') then
            ramp_value_reported <= ramp_value;
         end if;
       
         ----- ramp_value logic --------
         if (ramp_value_reg_en = '1'or cmd_collision_reg_en = '1') then
            ramp_value <= next_ramp_value;
         elsif( (cmd_mode_changing = '1' or realign_ramp2data = '1') and internal_cmd_mode_i = INTERNAL_RAMP ) then 
            ramp_value  <= step_minimum_i; 
         elsif((cmd_mode_changing = '1' or realign_ramp2data = '1') and internal_cmd_mode_i = INTERNAL_MEM) then
            ramp_value <= ext(awg_dat_i, WB_DATA_WIDTH);
            awg_addr   <= awg_addr_i;     
         else
            ramp_value <= ramp_value;
         end if;  
         ----- next_ramp_value logic --------
         if( (cmd_mode_changing = '1' or realign_ramp2data = '1') and internal_cmd_mode_i = INTERNAL_RAMP ) then 
            next_ramp_value  <= step_minimum_i;
         elsif(cmd_mode_changing = '1' and internal_cmd_mode_i = INTERNAL_MEM) then
            next_ramp_value <= ext(awg_dat_i, WB_DATA_WIDTH);
            awg_addr   <= awg_addr_i;         
         elsif(sync_number_i = next_toggle_sync and internal_cmd_mode_i = INTERNAL_RAMP)  then
            if(next_ramp_value < (step_maximum_i + 1 - step_size_i)) then
               next_ramp_value <= next_ramp_value + step_size_i;
            else
               next_ramp_value <= step_minimum_i;
            end if;
         elsif(sync_number_i = next_toggle_sync and internal_cmd_mode_i = INTERNAL_MEM) then
            next_ramp_value <= ext(awg_dat_i, WB_DATA_WIDTH);
            awg_addr   <= awg_addr_i;
         else
            next_ramp_value <= next_ramp_value;
            awg_addr   <= awg_addr;
         end if;
      end if;  --clk    
   end process i_ramp_awg_advance;   
   step_value_o <= ext(awg_addr, WB_DATA_WIDTH) when internal_cmd_mode_i = INTERNAL_MEM else ramp_value_reported;
   
   -------------------------------------------------------------------------------------------      
   i_timer_rst: process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         timer_rst <= '1';
      elsif (clk_i'event and clk_i = '1') then      
         timer_rst  <= '0';       
         if(internal_status_ack = '1') then
            timer_rst            <= '1';
         --else
         --   timer_rst <= '0';
         end if;
      end if;   
   end process i_timer_rst;
   -------------------------------------------------------------------------------------------
   -- timer for issuing internal status commands
   -------------------------------------------------------------------------------------------
   timer : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timer_rst,
      timer_count_o => time_elapsed);

   -------------------------------------------------------------------------------------------
   -- FSM Controller for the Command Scheduler 
   -------------------------------------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_state      <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         current_state      <= next_state;
      end if;
   end process;
   
   state_ns: process(current_state, dv_mode_i, ret_dat_req, external_dv_i, ack_i, seq_num, stop_seq_num_i,sync_number_i,
      internal_cmd_mode_i, internal_status_req, internal_rb_id, internal_wb_req, frame_sync_num,
      simple_cmd_req, rdy_for_data_i, ret_dat_in_progress, ret_dat_stop_req, data_timing_err_i, busy_i)
   begin
      next_state    <= current_state;
      case current_state is
         when IDLE =>
            if(ret_dat_req = '1') then               
               if (dv_mode_i = DV_INTERNAL or (dv_mode_i /= DV_INTERNAL and external_dv_i = '1')) then
                  -- Issue the first ret_dat immediately
                  next_state <= PROCESSING_RET_DAT;
               end if;
            -------------------------------------------------------------------------------------------
            -- Q: How do you differentiate between a STOP command when a data process has started from a STOP command when a process hasn't?
            -- A: A STOP immediately de-asserts ret_dat_req during a data acquisition, but leaves ret_dat_in_progress asserted.
            --    But when a data process is not in progress, ret_dat_in_progress = '0'.
            -------------------------------------------------------------------------------------------
            -- If a STOP command arrives before the first DV pulse arrives during an acquisition.
            elsif(ret_dat_stop_req = '1' and ret_dat_in_progress = '1') then
               -- Issue one last ret_dat.
               next_state <= UPDATE_FOR_NEXT;
            -- If a STOP command arrives and no data process was active.
            elsif(ret_dat_stop_req = '1' and ret_dat_in_progress = '0') then
               next_state <= IDLE;
            elsif(simple_cmd_req = '1') then
               next_state <= SIMPLE;
            -- time to issue the next internal ramp/awg command
            elsif((internal_cmd_mode_i = INTERNAL_RAMP or internal_cmd_mode_i = INTERNAL_MEM) and internal_wb_req = '1') then
               next_state <= INTERNAL_WB_PREP;
            -- time to issue the next internal housekeeping command
            elsif(internal_cmd_mode_i = INTERNAL_HOUSEKEEPING and internal_status_req = '1') then
               if(internal_rb_id = FPGA_TEMPERATURE) then
                  next_state <= FPGA_TEMP;
               elsif(internal_rb_id = CARD_TEMPERATURE) then
                  next_state <= CARD_TEMP;
               elsif(internal_rb_id = PSUC_STATUS) then
                  next_state <= PSC_STATUS;
               elsif(internal_rb_id = BOX_TEMPERATURE) then
                  next_state <= BOX_TEMP;
               end if;
            end if;

         when PROCESSING_RET_DAT =>
            if (ack_i = '1') then
               -- a healthy data process is here at the last frame
               if (seq_num /= stop_seq_num_i) then 
                  next_state <= UPDATE_FOR_NEXT;
               else 
                  next_state <= IDLE;
               end if;    
            elsif (busy_i = '0') then
               if(simple_cmd_req = '1') then                  
                  next_state <= SIMPLE;            
               elsif((internal_cmd_mode_i = INTERNAL_RAMP or internal_cmd_mode_i = INTERNAL_MEM) and 
                     (internal_wb_req = '1' and  sync_number_i /= frame_sync_num)) then --sync_number_i = next_toggle_sync and
                  next_state <= INTERNAL_WB_PREP;                        
               elsif(internal_cmd_mode_i = INTERNAL_HOUSEKEEPING and internal_status_req = '1') then
                  if(internal_rb_id = FPGA_TEMPERATURE) then
                     next_state <= FPGA_TEMP;
                  elsif(internal_rb_id = CARD_TEMPERATURE) then
                     next_state <= CARD_TEMP;
                  elsif(internal_rb_id = PSUC_STATUS) then
                     next_state <= PSC_STATUS;
                  elsif(internal_rb_id = BOX_TEMPERATURE) then
                     next_state <= BOX_TEMP;
                  end if;                                             
               end if;   
            end if;   

         when UPDATE_FOR_NEXT =>
            -- This state takes one cycle when in internal-dv mode, otherwise wait for the next dv-pulse
            if(data_timing_err_i = '1') then
               next_state <= REQ_LAST_DATA_PACKET;            
            -- if a stop command has arrived  
            elsif(ret_dat_req = '0') then
               -- Issue the last ret_dat command
               next_state <= REQ_LAST_DATA_PACKET;                 
            elsif(dv_mode_i = DV_INTERNAL or external_dv_i = '1') then 
               if(simple_cmd_req = '1') then                  
                  next_state <= SIMPLE;            
	       elsif((internal_cmd_mode_i = INTERNAL_RAMP or internal_cmd_mode_i = INTERNAL_MEM) and 
	             (internal_wb_req = '1' and  sync_number_i /= frame_sync_num)) then --sync_number_i = next_toggle_sync and
	          next_state <= INTERNAL_WB_PREP;                        
	       elsif(internal_cmd_mode_i = INTERNAL_HOUSEKEEPING and internal_status_req = '1') then
	          if(internal_rb_id = FPGA_TEMPERATURE) then
	             next_state <= FPGA_TEMP;
	          elsif(internal_rb_id = CARD_TEMPERATURE) then
	             next_state <= CARD_TEMP;
	          elsif(internal_rb_id = PSUC_STATUS) then
	             next_state <= PSC_STATUS;
	          elsif(internal_rb_id = BOX_TEMPERATURE) then
	             next_state <= BOX_TEMP;
	          end if;                                             
	       else    
                  next_state <= PROCESSING_RET_DAT;	          
               end if;
            end if;   

         when REQ_LAST_DATA_PACKET =>
            if(ack_i = '1') then
               next_state <= IDLE;
            end if;

         when SIMPLE | INTERNAL_WB_DATA | NEXT_INTERNAL_CMD =>
            if(ack_i = '1') then
               if(ret_dat_in_progress = '1') then
                     next_state <= PROCESSING_RET_DAT;
               else
                  next_state <= IDLE;
               end if;
            end if;

         when INTERNAL_WB_PREP =>
               next_state <= INTERNAL_WB_WAIT;
               
         when INTERNAL_WB_WAIT =>
               next_state <= INTERNAL_WB;

         when INTERNAL_WB =>
            if(rdy_for_data_i = '1') then
               next_state <= INTERNAL_WB_DATA;
            end if;

         when FPGA_TEMP | CARD_TEMP | PSC_STATUS | BOX_TEMP=>
            if(ack_i = '1') then
               next_state <= NEXT_INTERNAL_CMD;
            end if;
            
         when others =>
            next_state <= IDLE;
      end case;
   end process state_ns;

   -------------------------------------------------------------------------------------------
   -- FSM Output logic, Part 1:  cmd_queue interface signals
   -------------------------------------------------------------------------------------------
   state_out1: process(current_state, f_rx_card_addr, f_rx_param_id, f_rx_cmd_code, f_rx_num_data,
      f_rx_ret_dat_card_addr, f_rx_ret_dat_param_id, f_rx_ret_dat_data,
      internal_status_req, data_clk_i, step_card_addr_i, step_param_id_i, ramp_value,
      step_data_num_i, cmd_data_i, internal_wb_req, data_size)
   begin
      -- Default statements
      card_addr_o      <= (others => '0');
      param_id_o       <= (others => '0');
      cmd_code_o       <= (others => '0');
      data_size_o      <= (others => '0');
      data_clk_o       <= '0';
      internal_cmd_o   <= '0';
      data_o           <= (others => '0');   

      case current_state is            
         when UPDATE_FOR_NEXT | PROCESSING_RET_DAT | REQ_LAST_DATA_PACKET =>
            card_addr_o          <= f_rx_ret_dat_card_addr;
            param_id_o           <= f_rx_ret_dat_param_id;
            cmd_code_o           <= DATA;
            data_size_o          <= data_size;
            data_o               <= f_rx_ret_dat_data;

         when SIMPLE =>
            card_addr_o          <= f_rx_card_addr;
            param_id_o           <= f_rx_param_id;
            cmd_code_o           <= f_rx_cmd_code;
            data_size_o          <= f_rx_num_data;
            data_clk_o           <= data_clk_i;
            data_o               <= cmd_data_i;

         when INTERNAL_WB_PREP =>            
         when INTERNAL_WB_WAIT =>

         when INTERNAL_WB =>
            if(internal_wb_req = '1') then
               card_addr_o       <= step_card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);
               param_id_o        <= step_param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0);
               cmd_code_o        <= WRITE_BLOCK;
               data_size_o       <= step_data_num_i(BB_DATA_SIZE_WIDTH-1 downto 0); -- 1 word by default
               internal_cmd_o    <= '1';
               data_o            <= ramp_value;
            end if;

         when INTERNAL_WB_DATA =>
            if(internal_wb_req = '1') then
               card_addr_o       <= step_card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);
               param_id_o        <= step_param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0);
               cmd_code_o        <= WRITE_BLOCK;
               data_size_o       <= step_data_num_i(BB_DATA_SIZE_WIDTH-1 downto 0); -- 1 word by default
               -- cmd_queue is level-sensitive, not edge-sensitive.
               data_clk_o        <= '1';
               internal_cmd_o    <= '1';
               data_o            <= ramp_value;
           end if;

         when FPGA_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= ALL_FPGA_CARDS;
               param_id_o        <= FPGA_TEMP_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= FPGA_TEMP_DATA_SIZE;
               internal_cmd_o    <= '1';
            end if;

         when CARD_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= ALL_FPGA_CARDS;
               param_id_o        <= CARD_TEMP_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= CARD_TEMP_DATA_SIZE;
               internal_cmd_o    <= '1';
            end if;

         when PSC_STATUS =>
            if(internal_status_req = '1') then
               card_addr_o       <= POWER_SUPPLY_CARD;
               param_id_o        <= PSC_STATUS_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= PSC_STATUS_DATA_SIZE; -- 9 words
               internal_cmd_o    <= '1';
            end if;

         when BOX_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= CLOCK_CARD;
               param_id_o        <= BOX_TEMP_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= BOX_TEMP_DATA_SIZE;
               internal_cmd_o    <= '1';
            end if;   

         when others =>
            card_addr_o      <= (others => '0');
            param_id_o       <= (others => '0');
            cmd_code_o       <= (others => '0');
            data_size_o      <= (others => '0');
            data_clk_o       <= '0';
            internal_cmd_o   <= '0';
            data_o           <= (others => '0');                             
      end case;
   end process state_out1;
   
   -------------------------------------------------------------------------------------------
   -- FSM Output logic - Part 2: Internal control signals 
   -------------------------------------------------------------------------------------------
   state_out2: process(current_state, stop_seq_num_i, seq_num, frame_sync_num, sync_number_i,
      ack_i, dv_mode_i, external_dv_i, cmd_collision,
      ret_dat_req, internal_wb_req, simple_cmd_req, internal_cmd_mode_i, cmd_rdy_i,
      internal_status_req, internal_rb_id, ret_dat_stop_req, ret_dat_in_progress)
   begin
      -- default assignments
      inc_sync_num         <= '0';
      jump_sync_num        <= '0';
      override_sync_num_o  <= '0';

      load_seq_num         <= '0';
      inc_seq_num          <= '0';

      instr_rdy_o          <= '0';
      ret_dat_ack          <= '0';
      ret_dat_start        <= '0';
      ret_dat_done         <= '0';

      last_frame_o         <= '0';
      cmd_stop_o           <= '0';

      internal_wb_ack      <= '0';
      internal_status_ack  <= '0';

      update_next_toggle_sync <= '0';
      awg_addr_incr_o      <= '0';

      internal_rb_ack      <= '0';
      simple_cmd_ack       <= '0';
      f_rx_ret_dat_ack     <= '0';
      ramp_value_reg_en    <= '0';      
      cmd_collision_reg_en <= '0';

      case current_state is
         when IDLE =>
            -- ret_dat_req may be asserted for some time before the cmd_queue is ready for the first ret_dat command
            -- Thus slide the sync number until the cmd_queue accepts the ret_dat command
            if(ret_dat_req = '1') then
               inc_sync_num <= '1';
               load_seq_num  <= '1';
	       ret_dat_start <= '1';	       

               -- Ack fibre_rx 1 cycle before starting the data process to free up fibre_rx for incoming (stop) cmds
               if(dv_mode_i = DV_INTERNAL) then
                  f_rx_ret_dat_ack <= '1';
               -- Bugfix: if the MCE sources DV pulses from the sync box, but doesn't ever receive them, 
               -- we need to free up fibre receive, so STOP command can be received!!
               elsif(dv_mode_i /= DV_INTERNAL and cmd_rdy_i = '1') then
                  f_rx_ret_dat_ack <= '1';
               end if;
            -- If a STOP command arrives before the first DV pulse arrives during an acquisition.
            elsif(ret_dat_stop_req = '1' and ret_dat_in_progress = '1') then
               -- Do not acknowledge yet (this is done in REQ_LAST_DATA_PACKET)
               -- Return a single data packet
               null;
            -- If a STOP command arrives and no data process was active.
            elsif(ret_dat_stop_req = '1' and ret_dat_in_progress = '0') then
               -- Acknowledge the command and reply -- but do not return any data packets
               ret_dat_ack <= '1';
               f_rx_ret_dat_ack <= '1';
            elsif simple_cmd_req = '1' then
               null;
            elsif internal_wb_req = '1' then 
               update_next_toggle_sync <= '1';
            elsif(internal_cmd_mode_i = INTERNAL_HOUSEKEEPING and internal_status_req = '1') then
               if(internal_rb_id < NUM_HOUSEKEEPING_CMD_TYPES ) then -- a valid housekeeping command
                  null;
               end if;
            end if;

         when PROCESSING_RET_DAT =>
            instr_rdy_o <= '1';
            if(seq_num = stop_seq_num_i or ret_dat_stop_req = '1') then -- hesitantly added stop-check, hmmm
               last_frame_o <= '1';
            end if;
                     
            if(ret_dat_stop_req = '1') then
               cmd_stop_o          <= '1';
               -- override_sync_num_o is asserted to notify the cmd_queue to issue the command immediately,
               -- without waiting for the next sync pulse, which may never arrive if the reason that the
               -- MCE data acquisition has frozen is because the Sync Box fibre is broken/ disconnected.
               override_sync_num_o <= '1';
            end if;

            if(ack_i = '1') then 
               if (seq_num /= stop_seq_num_i) then 
                  if ((internal_cmd_mode_i = INTERNAL_RAMP or internal_cmd_mode_i = INTERNAL_MEM) and 
                       internal_wb_req = '1' and sync_number_i /= frame_sync_num) then
                     instr_rdy_o <= '0';
                  end if;   
                  if (cmd_collision = '1') then
                     cmd_collision_reg_en <= '1';
                  end if;   
               else               
                  ret_dat_done <= '1';
                  ret_dat_ack <= '1';
                  -- De-assert instr_rdy_o immediately to prevent cmd_queue from re-latching it
                  instr_rdy_o <= '0';
                  f_rx_ret_dat_ack <= '1';
               end if;   
            end if;

         when UPDATE_FOR_NEXT =>            
            -- Either of these conditions are only met on the last clock period in this state.
            if(dv_mode_i = DV_INTERNAL) then
               jump_sync_num <= '1';
               inc_seq_num  <= '1';

               if(ret_dat_req = '0') then
                  f_rx_ret_dat_ack <= '1';
               end if;

            elsif(dv_mode_i /= DV_INTERNAL and external_dv_i = '1') then
               -- Timing of the DV pulse dictates the next data packet, so a ret_dat is issued on the sync# immediately after DV pulse
               -- we slide the sync number until the DV packet/pulse arrives, 
               inc_sync_num <= '1';
               inc_seq_num <= '1';

               if(ret_dat_req = '0') then
                  f_rx_ret_dat_ack <= '1';
               --elsif(ret_dat_req = '1' and external_dv_i = '1') then
               --   null;
               end if;
            end if;
            if(seq_num = stop_seq_num_i) then
	       last_frame_o <= '1';
	    end if;

         when REQ_LAST_DATA_PACKET =>
            instr_rdy_o       <= '1';
            last_frame_o      <= '1';
            
            -- Assert the following signals if a STOP command has been received:
            if(ret_dat_stop_req = '1') then
               cmd_stop_o          <= '1';
               -- override_sync_num_o is asserted to notify the cmd_queue to issue the command immediately,
               -- without waiting for the next sync pulse, which may never arrive if the reason that the
               -- MCE data acquisition has frozen is because the Sync Box fibre is broken/ disconnected.
               override_sync_num_o <= '1';
            end if;

            if(ack_i = '1') then
               -- De-assert instr_rdy_o immediately to prevent cmd_queue from re-latching it
               instr_rdy_o <= '0';
               ret_dat_ack <= '1';
               ret_dat_done <= '1';
               f_rx_ret_dat_ack <= '1';
            end if;

         when SIMPLE =>
            -- isolate the internal ready signals (ret_dat_rdy, etc) from the fibre_rx rdy (cmd_rdy_i).
            -- This is necessary to receive STOP commands when the initial ret_dat has not been processed yet (i.e. a ret_dat with no dv pulses)
            instr_rdy_o <= simple_cmd_req;

            if(ack_i = '1') then
               simple_cmd_ack <= '1';
            end if;

         when INTERNAL_WB_PREP =>
            awg_addr_incr_o <= '1';
               
         when INTERNAL_WB_WAIT =>
            
         when INTERNAL_WB =>
            instr_rdy_o <= '1';

         when INTERNAL_WB_DATA =>
            instr_rdy_o       <= '1';
            if(ack_i = '1') then
               internal_wb_ack <= '1';            
               ramp_value_reg_en <= '1';
            end if;

         when FPGA_TEMP | CARD_TEMP | PSC_STATUS | BOX_TEMP =>
            instr_rdy_o <= '1';
            if(ack_i = '1') then
               internal_status_ack <= '1';
            end if;

         when NEXT_INTERNAL_CMD =>
            internal_status_ack <= '1';
            internal_rb_ack <= '1';

         when others =>
      end case;
   end process state_out2;

end rtl;