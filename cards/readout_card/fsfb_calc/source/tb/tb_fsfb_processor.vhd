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
-- tb_fsfb_processor.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Testbench for the first stage feedback processor block
--
-- This bench investigates the behaviour of the first stage feedback processor.  It looks into
-- the three different servo modes:  constant, ramp and lock.  The focus is on mode selection and
-- the arithmetic correctness.
--
--
-- Revision history:
-- 
-- $Log: tb_fsfb_processor.vhd,v $
-- Revision 1.2  2004/11/09 17:54:12  anthonyk
-- Various updates to reflect modified fsfb_processor definitions.
--
-- Revision 1.1  2004/10/22 22:19:41  anthonyk
-- Initial release
--
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;

entity tb_fsfb_processor is


end tb_fsfb_processor;




architecture test of tb_fsfb_processor is

   -- constant/signal declarations

   constant clk_period               :     time      := 20 ns;   -- 50 MHz clock period
   constant num_clk_row              :     integer   := 10;      -- number of clock cycles per row
   constant num_row_frame            :     integer   := 3;       -- number of rows per frame
   constant coadd_done_cyc           :     integer   := 5;       -- cycle number at which coadd_done occurs
   constant num_ramp_frame_cycles    :     integer   := 2;       -- num of frame_cycles for fixed ramp output
   constant lock_dat_msb_pos         :     integer   := 30;      -- most significant bit position of lock mode data output 
    
     
   shared variable endsim            :     boolean   := false;   -- simulation window

   signal rst                        :     std_logic := '1';     -- global reset
   signal processor_clk_i            :     std_logic := '0';     -- global clock
   
   -- testbench signals
   -- timing references
   signal row_counter                :     std_logic_vector(5 downto 0);
   signal row_switch                 :     std_logic;
   signal frame_counter              :     std_logic_vector(5 downto 0);
   signal restart_frame              :     std_logic;
   
   -- upstream block inputs for lock mode testing
   signal adc_coadd_done_i           :     std_logic;
   signal adc_coadd_dat_i            :     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
   signal adc_diff_dat_i             :     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
   signal adc_integral_dat_i         :     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
   
   -- shift register for coadd_done
   signal coadd_done_shift           :     std_logic_vector(63 downto 0);
   
   -- io controller inputs for ramp mode testing
   signal io_ramp_update_new_i       :     std_logic;
   signal io_initialize_window_ext_i :     std_logic;
   signal io_fsfb_dat_rdy_i          :     std_logic;
   signal io_fsfb_dat_i              :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
   
   -- counter for fixed ramp level update
   signal ramp_counter               :     std_logic_vector(5 downto 0);
   
   -- wishbone inputs 
   signal ws_servo_mode_i            :     std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
   signal ws_ramp_step_size_i        :     std_logic_vector(RAMP_STEP_WIDTH-1 downto 0); 
   signal ws_ramp_amp_i              :     std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
   signal ws_const_val_i             :     std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal ws_p_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal ws_i_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal ws_d_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal ws_z_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   
   -- outputs from the processor
   signal processor_update_o         :     std_logic;
   signal processor_dat_o            :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
   signal processor_lock_en_o        :     std_logic;
      
      
   -- procedure for coefficient configuration
   -- Configures the PIDZ coefficients upon config_i = '1' for num_repeat times
   procedure pidz_config (
      p_coeff         : in integer;
      i_coeff         : in integer;
      d_coeff         : in integer;
      z_coeff         : in integer;
      num_repeat      : in integer;
      signal config_i : in std_logic;
      signal p_dat_o  : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      signal i_dat_o  : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      signal d_dat_o  : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      signal z_dat_o  : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0)
     ) is
               
   begin
      for index in 1 to num_repeat loop
      wait until config_i = '1';
      p_dat_o <= conv_std_logic_vector(p_coeff + index, COEFF_QUEUE_DATA_WIDTH);
      i_dat_o <= conv_std_logic_vector(i_coeff + index, COEFF_QUEUE_DATA_WIDTH);
      d_dat_o <= conv_std_logic_vector(d_coeff + index, COEFF_QUEUE_DATA_WIDTH);
      z_dat_o <= conv_std_logic_vector(z_coeff + index, COEFF_QUEUE_DATA_WIDTH);
      end loop;
   end procedure pidz_config;
 
 
   -- procedure for lock mode test set up
   -- set up various inputs for num_repeat times
   procedure test_lock_mode (
      coadd_dat             : in integer; 
      diff_dat              : in integer; 
      integral_dat          : in integer;
      num_repeat            : in integer;
      signal update_i       : in std_logic;
      signal servo_mode_o   : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      signal coadd_dat_o    : out std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
      signal diff_dat_o     : out std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
      signal integral_dat_o : out std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0)
      ) is 
   
   begin
      servo_mode_o      <= conv_std_logic_vector(3, SERVO_MODE_SEL_WIDTH);
      for index in 1 to num_repeat loop
         wait until update_i = '1';
         coadd_dat_o    <= conv_std_logic_vector(coadd_dat + index, COADD_QUEUE_DATA_WIDTH);
         diff_dat_o     <= conv_std_logic_vector(diff_dat + 2*index, COADD_QUEUE_DATA_WIDTH);
         integral_dat_o <= conv_std_logic_vector(integral_dat + 3*index, COADD_QUEUE_DATA_WIDTH);     
      end loop;
   end procedure test_lock_mode;
   

   -- procedure for constant mode test set up
   procedure test_const_mode (
      const_val : in integer;
      signal servo_mode_o : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      signal const_val_o  : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0)
      ) is
   begin
      servo_mode_o <= conv_std_logic_vector(1, SERVO_MODE_SEL_WIDTH);
      const_val_o  <= conv_std_logic_vector(const_val, CONST_VAL_WIDTH);
   end procedure test_const_mode;
   

   -- procedure for ramp mode test set up
   procedure test_ramp_mode (
      ramp_step_size          : in integer;
      ramp_amp                : in integer;
      dat                     : in integer;
      signal dat_rdy          : in std_logic;
      add_sub                 : in std_logic;
      signal servo_mode_o     : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      signal ramp_step_size_o : out std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
      signal ramp_amp_o       : out std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
      signal dat_o            : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0)
      ) is
   begin      
      servo_mode_o     <= conv_std_logic_vector(2, SERVO_MODE_SEL_WIDTH);
      ramp_step_size_o <= conv_std_logic_vector(ramp_step_size, RAMP_STEP_WIDTH);
      ramp_amp_o       <= conv_std_logic_vector(ramp_amp, RAMP_AMP_WIDTH);
      
      wait until dat_rdy = '1';
      dat_o(FSFB_QUEUE_DATA_WIDTH)            <= add_sub;
      dat_o(FSFB_QUEUE_DATA_WIDTH-1 downto 0) <= conv_std_logic_vector(dat, FSFB_QUEUE_DATA_WIDTH);
      
   end procedure test_ramp_mode;
   

  -- procedure for generating initialize_window_ext_i input
  procedure init_window(
      signal restart_frame_aligned_i : in std_logic;
      signal init_window_o           : out std_logic
      ) is
   begin
      wait until restart_frame_aligned_i = '1';
      wait for 1.1*clk_period;
      init_window_o <= '1';
      wait until restart_frame_aligned_i = '1';
      wait for (1+num_clk_row)*clk_period + 0.1*clk_period;
      init_window_o <= '0';
   end procedure init_window;
      
   
begin

   rst <= '0' after 1000 * clk_period;
   
   
   -- end simulation after 50000*clk_period
   end_sim : process
   begin 
      wait for 50000* clk_period;
      endsim := true;
   end process end_sim;


   -- Generate a 50MHz clock (ie 20 ns period)
   clk_gen : process
   variable test : integer;
   begin
      if endsim = false then
         processor_clk_i <= not processor_clk_i;
         wait for clk_period/2;
      else
         report "Simulation Finished....."
         severity FAILURE;
      end if;   
   end process clk_gen;
 
 
   -- Generate a row, frame reference for various inputs used by the processor
   row_ref : process (rst, processor_clk_i)
   begin
      if rst = '1' then
         row_counter <= conv_std_logic_vector(num_clk_row-1, 6);    -- 64 Max
         row_switch  <= '0';
      
      elsif (processor_clk_i'event and processor_clk_i = '1') then
         if (row_counter = 0) then
            row_counter <= conv_std_logic_vector(num_clk_row-1, 6);
            row_switch  <= '1';
         else
            row_counter <= row_counter - 1;
            row_switch  <= '0';
         end if;
      end if;
   end process row_ref;
         
   frame_ref : process (rst, processor_clk_i)
   begin
      if rst = '1' then
         frame_counter <= (others => '0');
         restart_frame <= '0';
         
      elsif (processor_clk_i'event and processor_clk_i = '1') then
         if (row_counter = 0 and frame_counter = 0) then
            restart_frame <= '1';
         else
            restart_frame <= '0';
         end if;
         
         if (row_switch = '1') then
            if (frame_counter = 0) then      
               frame_counter <= conv_std_logic_vector(num_row_frame-1, 6);   -- 41 Max   
            else
               frame_counter <= frame_counter - 1;
            end if;
         end if;
      end if;
   end process frame_ref;
   
     
   -- Generate coadd done input from upstream ADC block
   coadd_done_gen : process (rst, processor_clk_i)
   begin
      if rst = '1' then
         coadd_done_shift    <= (others => '0');
      elsif (processor_clk_i'event and processor_clk_i = '1') then
         coadd_done_shift(63 downto 1) <= coadd_done_shift(62 downto 0);
         coadd_done_shift(0) <= row_switch;
      end if;
   end process coadd_done_gen;
   
   adc_coadd_done_i <= coadd_done_shift(coadd_done_cyc-1);
   
   -- This window indicates when to latch the new ramp result from add/sub operation
   -- If not active, the data written to the current queue remains unchanged.
   fixed_ramp : process (rst, processor_clk_i)
   begin 
      if (rst = '1') then
         io_ramp_update_new_i <= '0';
         ramp_counter         <= (others => '0');
      elsif (processor_clk_i'event and processor_clk_i = '1') then
         if (restart_frame = '1')  then
            if (ramp_counter = 0) then
               io_ramp_update_new_i <= '1';       
               ramp_counter         <= conv_std_logic_vector(num_ramp_frame_cycles, 6);  -- 63 Max
            else     
               io_ramp_update_new_i <= '0';
               ramp_counter         <= ramp_counter - 1;
            end if;
         end if;
       end if;
    end process fixed_ramp;
         

   -- unit under test:  first stage feedback processor
   -- it encapsulates two sub-blocks:  
   -- 1) first stage feedback processor (lock mode)
   -- 2) first stage feedback processor (ramp mode)
   
   UUT : fsfb_processor
      generic map (
         lock_dat_left            => lock_dat_msb_pos        
      )
      port map (
         rst_i                    => rst,
   	 clk_50_i                 => processor_clk_i,
   	 coadd_done_i             => adc_coadd_done_i,
   	 current_coadd_dat_i      => adc_coadd_dat_i,
   	 current_diff_dat_i       => adc_diff_dat_i,
   	 current_integral_dat_i   => adc_integral_dat_i,
   	 ramp_update_new_i        => io_ramp_update_new_i,
   	 initialize_window_ext_i  => io_initialize_window_ext_i,
   	 previous_fsfb_dat_rdy_i  => io_fsfb_dat_rdy_i,   
   	 previous_fsfb_dat_i      => io_fsfb_dat_i,   
   	 servo_mode_i             => ws_servo_mode_i,
   	 ramp_step_size_i         => ws_ramp_step_size_i,
   	 ramp_amp_i               => ws_ramp_amp_i,
   	 const_val_i              => ws_const_val_i,
   	 p_dat_i                  => ws_p_dat_i,
   	 i_dat_i                  => ws_i_dat_i,
   	 d_dat_i                  => ws_d_dat_i,
   	 z_dat_i                  => ws_z_dat_i,
         fsfb_proc_update_o       => processor_update_o,
         fsfb_proc_dat_o          => processor_dat_o,
         fsfb_proc_lock_en_o      => processor_lock_en_o
      );  
 
 
   -- set up PIDZ coefficients
   pidz_config(4, 3, 2, 1, 2, coadd_done_shift(2),
               ws_p_dat_i, ws_i_dat_i, ws_d_dat_i, ws_z_dat_i);
   
   -- pidz_config(2**32-4, 2**32-3, 2**32-2, 2**32-1, 2, coadd_done_shift(2),
   --               ws_p_dat_i, ws_i_dat_i, ws_d_dat_i, ws_z_dat_i);
   
   -- generate fsfb data ready signal 4 cycles after each row switch
   io_fsfb_dat_rdy_i <= coadd_done_shift(4);
   
   -- generate one instance of initialize_window_ext_i input
   initialize : process
   begin
      io_initialize_window_ext_i <= '0';
      wait for 1970*clk_period;
      init_window(restart_frame, io_initialize_window_ext_i);
      wait;
   end process initialize;
      
  
   -- main stimuli procedure 
   run_test : process 
   begin
      test_lock_mode(1, 2, 3, num_row_frame, adc_coadd_done_i, 
                     ws_servo_mode_i, adc_coadd_dat_i, adc_diff_dat_i, adc_integral_dat_i);
      --test_lock_mode(2**32-10, 2**32-9, 2**32-8, num_row_frame, adc_coadd_done_i, 
      --               ws_servo_mode_i, adc_coadd_dat_i, adc_diff_dat_i, adc_integral_dat_i);
      wait until restart_frame = '1';
      wait for 1*clk_period;
      
      test_const_mode(16383, ws_servo_mode_i, ws_const_val_i);
      
      wait until restart_frame = '1';
      wait for 1*clk_period;
      
      test_ramp_mode(4, 10, 0, io_fsfb_dat_rdy_i, '0',
                     ws_servo_mode_i, ws_ramp_step_size_i, ws_ramp_amp_i, io_fsfb_dat_i);
      
      wait until row_switch = '1';
      
      test_ramp_mode(4, 10, 6, io_fsfb_dat_rdy_i, '0',
                     ws_servo_mode_i, ws_ramp_step_size_i, ws_ramp_amp_i, io_fsfb_dat_i);
      --wait until row_switch = '1';
      --test_ramp_mode(4, 10, 4, io_fsfb_dat_rdy_i, '0',
      --               ws_servo_mode_i, ws_ramp_step_size_i, ws_ramp_amp_i, io_fsfb_dat_i);
      
      
      wait until restart_frame = '1';
      
      test_lock_mode(3, 2, 1, num_row_frame, adc_coadd_done_i, 
                           ws_servo_mode_i, adc_coadd_dat_i, adc_diff_dat_i, adc_integral_dat_i);
      --test_lock_mode(2**32-10, 2**32-9, 2**32-8, num_row_frame, adc_coadd_done_i, 
      --               ws_servo_mode_i, adc_coadd_dat_i, adc_diff_dat_i, adc_integral_dat_i);
      
      wait until restart_frame = '1';
      wait for 1*clk_period;
      
      test_const_mode(1638, ws_servo_mode_i, ws_const_val_i);
      
      wait until restart_frame = '1';
      wait for 1*clk_period;
      
      test_ramp_mode(4, 10, 6, io_fsfb_dat_rdy_i, '1',
                     ws_servo_mode_i, ws_ramp_step_size_i, ws_ramp_amp_i, io_fsfb_dat_i);
      
      wait until row_switch = '1';
      
      test_ramp_mode(4, 10, 2, io_fsfb_dat_rdy_i, '1',
                     ws_servo_mode_i, ws_ramp_step_size_i, ws_ramp_amp_i, io_fsfb_dat_i);

      
      wait until restart_frame = '1';

   end process run_test;
        
   
end test;

