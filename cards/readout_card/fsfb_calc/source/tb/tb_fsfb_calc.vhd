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
-- tb_fsfb_calc.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Testbench for the first stage feedback calculator block
--
-- This bench investigates the behaviour of the first stage feedback calculator.  The calculator
-- encapsulates fsfb io controller and processor.  The io controller in turn encapsulates fsfb queue
-- for storing the fsfb calculation result.
--
-- Revision history:
-- 
-- $Log: tb_fsfb_calc.vhd,v $
-- Revision 1.2  2004/10/25 18:03:12  anthonyk
-- Changed input port name num_rows_sub1 to num_rows_sub1_i
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

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.fsfb_calc_pack.all;


entity tb_fsfb_calc is


end tb_fsfb_calc;




architecture test of tb_fsfb_calc is

   -- constant/signal declarations

   constant clk_period                 :     time      := 20 ns;   -- 50 MHz clock period
   constant num_clk_row                :     integer   := 20;      -- number of clock cycles per row
   constant num_row_frame              :     integer   := 41;      -- number of rows per frame
   constant coadd_done_cyc             :     integer   := 6;       -- cycle number at which coadd_done occurs
   constant num_ramp_frame_cycles      :     integer   := 2;       -- num of frame_cycles for fixed ramp output
   
     
   shared variable endsim              :     boolean   := false;   -- simulation window

   signal rst_i                        :     std_logic := '0';     -- global reset
   signal calc_clk_i                   :     std_logic := '0';     -- global clock
   
   -- testbench signals
   -- timing references (provided by Frame Timing (ft) block)
   signal row_counter                  :     std_logic_vector(5 downto 0);
   signal ft_row_switch_i              :     std_logic;
   signal frame_counter                :     std_logic_vector(5 downto 0);
   signal ft_restart_frame_aligned_i   :     std_logic;
   signal ft_restart_frame_1row_post_i :     std_logic;
   signal delay_en                     :     std_logic;
   signal ft_initialize_window_i       :     std_logic  := '0';
   signal ft_num_rows_sub1_i           :     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
   
   -- upstream block inputs for lock mode testing
   signal adc_coadd_done_i             :     std_logic;
   signal adc_coadd_dat_i              :     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
   signal adc_diff_dat_i               :     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
   signal adc_integral_dat_i           :     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
   
   -- shift register for coadd done pulse generation
   signal coadd_done_shift             :     std_logic_vector(num_clk_row-1 downto 0);
   
   -- configuration related
   signal cfg_servo_mode_i             :     std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
   signal cfg_ramp_step_size_i         :     std_logic_vector(RAMP_STEP_WIDTH-1 downto 0); 
   signal cfg_ramp_amp_i               :     std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
   signal cfg_const_val_i              :     std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          
   signal cfg_num_ramp_frame_cycles_i  :     std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
   
   -- wishbone access (away from frame boundary)
   signal calc_ws_addr_i               :     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_ws_dat_o                :     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  
   -- PIDZ coefficient queues io  
   signal calc_p_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_p_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_p_dat_i_33              :     std_logic_vector(32 downto 0);
   signal calc_i_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_i_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_i_dat_i_33              :     std_logic_vector(32 downto 0);   
   signal calc_d_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_d_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_d_dat_i_33              :     std_logic_vector(32 downto 0);
   signal calc_z_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_z_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_z_dat_i_33              :     std_logic_vector(32 downto 0);
   
   
   signal pq_wraddr_i                  :     std_logic_vector(5 downto 0);
   signal iq_wraddr_i                  :     std_logic_vector(5 downto 0);
   signal dq_wraddr_i                  :     std_logic_vector(5 downto 0);
   signal zq_wraddr_i                  :     std_logic_vector(5 downto 0);
   
   signal pq_wrdata_i                  :     std_logic_vector(32 downto 0);
   signal iq_wrdata_i                  :     std_logic_vector(32 downto 0);
   signal dq_wrdata_i                  :     std_logic_vector(32 downto 0);
   signal zq_wrdata_i                  :     std_logic_vector(32 downto 0);   
   
   signal pq_wren_i                    :     std_logic;
   signal iq_wren_i                    :     std_logic;
   signal dq_wren_i                    :     std_logic;
   signal zq_wren_i                    :     std_logic;
      
   
   -- downstream filter interface
   signal calc_fltr_dat_rdy_o          :     std_logic;
   signal calc_fltr_dat_o              :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);

   -- downstream control interface
   signal calc_ctrl_dat_rdy_o          :     std_logic;
   signal calc_ctrl_dat_o              :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_ctrl_lock_en_o          :     std_logic;


   -- data to be written to the queue for the write operation
   signal dat                          :     integer;
   
   
   -- fsfb calc (UUT) component declaration
   component fsfb_calc is
      generic (
         start_val                 : integer := FSFB_QUEUE_INIT_VAL;                               -- value read from the queue when initialize_window_i is asserted
         lock_dat_left             : integer := MOST_SIG_LOCK_POS                                  -- most significant bit position of lock mode data output
         );
         
      port (
         rst_i                     : in     std_logic;                                             -- global reset
         clk_50_i                  : in     std_logic;                                             -- gobal clock 
         coadd_done_i              : in     std_logic;                                             -- done signal issued by coadd block to indicate coadd data valid (one-clk period pulse)
         current_coadd_dat_i       : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current coadded value 
         current_diff_dat_i        : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current difference
         current_integral_dat_i    : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current integral
         restart_frame_aligned_i   : in     std_logic;                                             -- start of frame signal
         restart_frame_1row_post_i : in     std_logic;                                             -- start of frame signal (1 row behind of actual frame start)
         row_switch_i              : in     std_logic;                                             -- row switch signal to indicate next clock cycle is the beginning of new row
         initialize_window_i       : in     std_logic;                                             -- frame window at which all values read equal to fixed preset parameter
         num_rows_sub1_i           : in     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
         servo_mode_i              : in     std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     -- servo mode selection 
         ramp_step_size_i          : in     std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          -- ramp step increments/decrements
         ramp_amp_i                : in     std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           -- ramp peak amplitude
         const_val_i               : in     std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          -- fs feedback constant value
         num_ramp_frame_cycles_i   : in     std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);           -- number of frame cycle ramp remained level 
         p_addr_o                  : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);   -- coefficient queue address/data inputs/outputs 
         p_dat_i                   : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- read-only operations
         i_addr_o                  : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
         i_dat_i                   : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         d_addr_o                  : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
         d_dat_i                   : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         z_addr_o                  : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
         z_dat_i                   : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         fsfb_ws_addr_i            : in     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
         fsfb_ws_dat_o             : out    std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
         fsfb_fltr_dat_rdy_o       : out    std_logic;                                             -- fs feedback queue current data ready 
         fsfb_fltr_dat_o           : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 
         fsfb_ctrl_dat_rdy_o       : out    std_logic;                                             -- fs feedback queue previous data ready
         fsfb_ctrl_dat_o           : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue previous data
         fsfb_ctrl_lock_en_o       : out    std_logic                                              -- control lock data mode enable
      );
   end component fsfb_calc;
  

   -- procedure for configuring PIDZ coefficient queues   
   procedure cfg_pidz(
      signal clk_i    : in  std_logic;
      start_val       : in  integer;
      signal p_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal i_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal d_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal z_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal p_dat_o  : out std_logic_vector(32 downto 0);
      signal i_dat_o  : out std_logic_vector(32 downto 0);        
      signal d_dat_o  : out std_logic_vector(32 downto 0);           
      signal z_dat_o  : out std_logic_vector(32 downto 0);
      signal p_wren_o : out std_logic;
      signal i_wren_o : out std_logic;
      signal d_wren_o : out std_logic;
      signal z_wren_o : out std_logic
      ) is
      
   begin
      for index in 0 to 40 loop
         wait until clk_i = '0';
         p_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         i_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         d_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         z_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         p_dat_o  <= conv_std_logic_vector(start_val+index, 33);
         i_dat_o  <= conv_std_logic_vector(start_val+2*index, 33);
         d_dat_o  <= conv_std_logic_vector(start_val+3*index, 33);
         z_dat_o  <= conv_std_logic_vector(start_val+4*index, 33);
         p_wren_o <= '1';
         i_wren_o <= '1';
         d_wren_o <= '1';
         z_wren_o <= '1';
      end loop;
      wait until clk_i = '0';
      p_wren_o <= '0';
      i_wren_o <= '0';
      d_wren_o <= '0';
      z_wren_o <= '0';
   end procedure cfg_pidz;
   

   -- procedure for wishbone access to the fsfb queues
   procedure ws_access(
      signal clk_i     : in  std_logic;
      signal rd_addr_o : out std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0)
      ) is
   
   begin
      for index in 0 to 40 loop
         wait until clk_i = '0';
         rd_addr_o <= conv_std_logic_vector(index, FSFB_QUEUE_ADDR_WIDTH);
      end loop;
   end procedure ws_access;
   
   
   -- procedure for generating initialize_window_i input
   procedure init_window(
      signal restart_frame_aligned_i : in  std_logic;
      signal init_window_o           : out std_logic
      ) is
   begin
      wait until restart_frame_aligned_i = '1';
      wait for 1.1*clk_period;                                -- 0.1*clk_period is needed to avoid simulation issue
      init_window_o <= '1';
      wait until restart_frame_aligned_i = '1';
      wait for 1.1*clk_period;
      init_window_o <= '0';
   end procedure init_window;
   
   
   -- procedure for test mode setting
   procedure cfg_test_mode(
      servo_mode_i               : in  integer;
      ramp_step_size_i           : in  integer;
      ramp_amp_i                 : in  integer;
      ramp_frame_cycles_i        : in  integer;
      const_val_i                : in  integer;
      signal servo_mode_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      signal ramp_step_size_o    : out std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
      signal ramp_amp_o          : out std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
      signal ramp_frame_cycles_o : out std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
      signal const_val_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0)
      ) is
   begin
      servo_mode_o <= conv_std_logic_vector(servo_mode_i, SERVO_MODE_SEL_WIDTH);
      sel : case servo_mode_i is
         -- constant mode setting
         when 1 => const_val_o         <= conv_std_logic_vector(const_val_i, CONST_VAL_WIDTH);
                   ramp_step_size_o    <= (others => 'X');
                   ramp_amp_o          <= (others => 'X');
                   ramp_frame_cycles_o <= (others => 'X');
         -- ramp mode setting
         when 2 => const_val_o         <= (others => 'X');
                   ramp_step_size_o    <= conv_std_logic_vector(ramp_step_size_i, RAMP_STEP_WIDTH);
                   ramp_amp_o          <= conv_std_logic_vector(ramp_amp_i, RAMP_AMP_WIDTH);
                   ramp_frame_cycles_o <= conv_std_logic_vector(ramp_frame_cycles_i, RAMP_CYC_WIDTH);                   
         -- lock mode setting and invalid
         when others => const_val_o         <= (others => 'X');
                        ramp_step_size_o    <= (others => 'X');
		        ramp_amp_o          <= (others => 'X');
                        ramp_frame_cycles_o <= (others => 'X');
      end case sel;
   end procedure cfg_test_mode;
   
   
begin

   rst_i <= '1', '0' after 1000 * clk_period;
   
   ft_num_rows_sub1_i <= conv_std_logic_vector(40, FSFB_QUEUE_ADDR_WIDTH);
   

   -- Configure the P,I,D,Z coefficient values
   pidz_setup : process 
   begin
      wait until rst_i = '1';
      cfg_pidz(calc_clk_i, 1,
               pq_wraddr_i, iq_wraddr_i, dq_wraddr_i, zq_wraddr_i,
               pq_wrdata_i, iq_wrdata_i, dq_wrdata_i, zq_wrdata_i,
               pq_wren_i, iq_wren_i, dq_wren_i, zq_wren_i);
      wait;
   end process pidz_setup;
      
   

   -- Generate a 50MHz clock (ie 20 ns period)
   clk_gen : process
   begin
      if endsim = false then
         calc_clk_i <= not calc_clk_i;
         wait for clk_period/2;
      else
         report "Simulation Finished....."
         severity FAILURE;
      end if;     
   end process clk_gen;
   

   -- Generate a row, frame reference for various inputs used by the processor
   row_ref : process (rst_i, calc_clk_i)
   begin
      if rst_i = '1' then
         row_counter      <= conv_std_logic_vector(num_clk_row-1, 6);    -- 64 Max
         ft_row_switch_i  <= '0';
      
      elsif (calc_clk_i'event and calc_clk_i = '1') then
         if (row_counter = 0) then
            row_counter      <= conv_std_logic_vector(num_clk_row-1, 6);
            ft_row_switch_i  <= '1';
         else
            row_counter      <= row_counter - 1;
            ft_row_switch_i  <= '0';
         end if;
      end if;
   end process row_ref;
         
   frame_ref : process (rst_i, calc_clk_i)
   begin
      if rst_i = '1' then
         frame_counter              <= (others => '0');
         ft_restart_frame_aligned_i <= '0';
         
      elsif (calc_clk_i'event and calc_clk_i = '1') then
         if (row_counter = 0 and frame_counter = 0) then
            ft_restart_frame_aligned_i <= '1';
         else
            ft_restart_frame_aligned_i <= '0';
         end if;
         
         if (ft_row_switch_i = '1') then
            if (frame_counter = 0) then      
               frame_counter <= conv_std_logic_vector(num_row_frame-1, 6);   -- 41 Max   
            else
               frame_counter <= frame_counter - 1;
            end if;
         end if;
      end if;
   end process frame_ref;
   
   delay_en_proc : process (calc_clk_i, rst_i)   
   begin
      if (rst_i = '1') then
         delay_en <= '0';
      elsif (calc_clk_i'event and calc_clk_i = '1') then
         -- indication of start of first row in frame N
         if (ft_restart_frame_aligned_i = '1' and ft_row_switch_i = '1') then
            delay_en <= '1';
         -- indication of start of second row in frame N+1   
         elsif (ft_row_switch_i = '1') then
            delay_en <= '0';
         end if;
      end if;
   end process delay_en_proc;
   

   -- delayed restart_frame_aligned_i control signal output
   -- the output is now delayed to the 1st row instead of the last one
   ft_restart_frame_1row_post_i <= ft_row_switch_i when delay_en ='1' else '0';   
   

   -- Generate the fsfb_proc_update_i input
   coadd_done_gen : process (rst_i, calc_clk_i)
   begin
      if rst_i = '1' then
         coadd_done_shift <= (others => '0');
      elsif (calc_clk_i'event and calc_clk_i = '1') then
         coadd_done_shift(num_clk_row-1 downto 1) <= coadd_done_shift(num_clk_row-2 downto 0);
         coadd_done_shift(0)                      <= ft_row_switch_i;
      end if;
   end process coadd_done_gen;
   
   adc_coadd_done_i <= coadd_done_shift(coadd_done_cyc-1);   
   

   -- Generate the data inputs from ADC using a free-running counter
   dat_counter : process (rst_i, calc_clk_i)
   begin
      if rst_i = '1' then
         dat <= 0;
      elsif (calc_clk_i'event and calc_clk_i = '1') then
         dat <= dat + 1;
      end if;
   end process dat_counter;
   
   adc_dat_gen : process (adc_coadd_done_i)
   begin
      if adc_coadd_done_i = '1' then
         adc_coadd_dat_i    <= conv_std_logic_vector(dat, COADD_QUEUE_DATA_WIDTH);
         adc_diff_dat_i     <= conv_std_logic_vector(2*dat, COADD_QUEUE_DATA_WIDTH);
         adc_integral_dat_i <= conv_std_logic_vector(3*dat, COADD_QUEUE_DATA_WIDTH);
      end if;
   end process adc_dat_gen;
   
   

   -- unit under test:  first stage feedback calculator block
   UUT : fsfb_calc
      generic map (
         start_val                 => 0,
         lock_dat_left             => 30
         )
      port map (
         rst_i                     => rst_i,
         clk_50_i                  => calc_clk_i,
         coadd_done_i              => adc_coadd_done_i,
         current_coadd_dat_i       => adc_coadd_dat_i,
         current_diff_dat_i        => adc_diff_dat_i,
         current_integral_dat_i    => adc_integral_dat_i,
         restart_frame_aligned_i   => ft_restart_frame_aligned_i,
         restart_frame_1row_post_i => ft_restart_frame_1row_post_i,
         row_switch_i              => ft_row_switch_i,
         initialize_window_i       => ft_initialize_window_i,
         num_rows_sub1_i           => ft_num_rows_sub1_i,
         servo_mode_i              => cfg_servo_mode_i, 
         ramp_step_size_i          => cfg_ramp_step_size_i,
         ramp_amp_i                => cfg_ramp_amp_i,
         const_val_i               => cfg_const_val_i,
         num_ramp_frame_cycles_i   => cfg_num_ramp_frame_cycles_i, 
         p_addr_o                  => calc_p_addr_o,
         p_dat_i                   => calc_p_dat_i,
         i_addr_o                  => calc_i_addr_o, 
         i_dat_i                   => calc_i_dat_i,
         d_addr_o                  => calc_d_addr_o,
         d_dat_i                   => calc_d_dat_i,
         z_addr_o                  => calc_z_addr_o,
         z_dat_i                   => calc_z_dat_i,
         fsfb_ws_addr_i            => calc_ws_addr_i,
         fsfb_ws_dat_o             => calc_ws_dat_o,
         fsfb_fltr_dat_rdy_o       => calc_fltr_dat_rdy_o,
         fsfb_fltr_dat_o           => calc_fltr_dat_o,
         fsfb_ctrl_dat_rdy_o       => calc_ctrl_dat_rdy_o,
         fsfb_ctrl_dat_o           => calc_ctrl_dat_o,
         fsfb_ctrl_lock_en_o       => calc_ctrl_lock_en_o
   );      
      

   -- Instantiate P coefficient queue
   p_queue : fsfb_queue 
      port map (
         data                     => pq_wrdata_i,
         wraddress                => pq_wraddr_i,
         rdaddress_a              => calc_p_addr_o,
         rdaddress_b              => calc_p_addr_o,
         wren                     => pq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_p_dat_i_33,
         qb                       => open
         );

   calc_p_dat_i <= calc_p_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);         
   

   -- Instantiate I coefficient queue
   i_queue : fsfb_queue 
      port map (
         data                     => iq_wrdata_i,
         wraddress                => iq_wraddr_i,
         rdaddress_a              => calc_i_addr_o,
         rdaddress_b              => calc_i_addr_o,
         wren                     => iq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_i_dat_i_33,
         qb                       => open
         );
         
   calc_i_dat_i <= calc_i_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   

   -- Instantiate D coefficient queue
   d_queue : fsfb_queue 
      port map (
         data                     => dq_wrdata_i,
         wraddress                => dq_wraddr_i,
         rdaddress_a              => calc_d_addr_o,
         rdaddress_b              => calc_d_addr_o,
         wren                     => dq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_d_dat_i_33,
         qb                       => open
         );

   calc_d_dat_i <= calc_d_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         

   -- Instantiate Z coefficient queue
   z_queue : fsfb_queue 
      port map (
         data                     => zq_wrdata_i,
         wraddress                => zq_wraddr_i,
         rdaddress_a              => calc_z_addr_o,
         rdaddress_b              => calc_z_addr_o,
         wren                     => zq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_z_dat_i_33,
         qb                       => open
         );

   calc_z_dat_i <= calc_z_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   
   
   -- Wishbone read access
   ws_rd_fsfb : process
   begin
      
      wait for 500*clk_period;
      ws_access(calc_clk_i, calc_ws_addr_i);
   
   end process ws_rd_fsfb;
      

   -- Main test stimuli
   run_test : process 
   begin
            
      for index in 1 to 2 loop
      
      
         wait until ft_restart_frame_aligned_i = '1';
         wait for clk_period;
  
         wait until ft_restart_frame_aligned_i = '1';
         wait for clk_period;

         wait for 20*num_clk_row*clk_period;
        
         -- ramp mode testing   
         cfg_test_mode(2, 2, 5, 1, 2**CONST_VAL_WIDTH-1,
                       cfg_servo_mode_i, cfg_ramp_step_size_i, cfg_ramp_amp_i,
                       cfg_num_ramp_frame_cycles_i, cfg_const_val_i);          
   
         init_window(ft_restart_frame_aligned_i, ft_initialize_window_i);
      
         -- wait for about 10 frame times
         wait for 10*41*num_clk_row*clk_period;
         wait for 20*num_clk_row*clk_period;
   
         -- const mode testing
         cfg_test_mode(1, 0, 0, 0, 2**CONST_VAL_WIDTH-1,
                       cfg_servo_mode_i, cfg_ramp_step_size_i, cfg_ramp_amp_i,
                       cfg_num_ramp_frame_cycles_i, cfg_const_val_i);          
      
         init_window(ft_restart_frame_aligned_i, ft_initialize_window_i);
      
      
         -- wait for about 10 frame times
         wait for 10*41*num_clk_row*clk_period;
         wait for 20*num_clk_row*clk_period;
         
         -- ramp mode testing
         cfg_test_mode(2, 3, 9, 3, 2**CONST_VAL_WIDTH-1,
                       cfg_servo_mode_i, cfg_ramp_step_size_i, cfg_ramp_amp_i,
                       cfg_num_ramp_frame_cycles_i, cfg_const_val_i);          

         init_window(ft_restart_frame_aligned_i, ft_initialize_window_i);
      
         -- wait for about 30 frame times
         wait for 30*41*num_clk_row*clk_period;
         wait for 20*num_clk_row*clk_period;
      
         -- lock mode testing
         cfg_test_mode(3, 0, 0, 0, 0,
                       cfg_servo_mode_i, cfg_ramp_step_size_i, cfg_ramp_amp_i,
                       cfg_num_ramp_frame_cycles_i, cfg_const_val_i);          
      
         init_window(ft_restart_frame_aligned_i, ft_initialize_window_i);
      
      
         -- run for about 30 frame times
         wait for 30*41*num_clk_row*clk_period;
         wait for 20*num_clk_row*clk_period;
      
      end loop;
      
      -- end simulation
      endsim := true;
      
   end process run_test;
   
end test;

