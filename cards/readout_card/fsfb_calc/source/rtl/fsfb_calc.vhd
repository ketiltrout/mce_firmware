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
-- fsfb_calc.vhd
--
-- Project:   SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- First stage feedback calculation firmware
--
-- This block is the top level block of the first stage feedback calculator.  It is
-- responsible for first stage feedback calculation in all three servo modes which 
-- are constant, ramp, and lock.  Calculation is performed by the subblock fsfb_processor.
-- The results are stored into the two fsfb_queue's.  The handling of all inputs and 
-- outputs to the two fsfb_queue's is taken care by the subblock fsfb_io_controller.
-- No other subblock has direct interface with the two fsfb_queue's.
--
--
-- Instantiates:
-- 1. fsfb_io_controller
-- 2. fsfb_processor
-- 3. fsfb_queue's (two of these)
--
-- Revision history:
-- 
-- $Log: fsfb_calc.vhd,v $
-- Revision 1.13  2010/03/12 20:50:17  bburger
-- BB: changed lock_dat_left to lock_dat_lsb
--
-- Revision 1.12  2009/05/27 01:27:58  bburger
-- BB: Increased the filter storage size to make filtered data available on demand
--
-- Revision 1.11  2006/03/14 22:49:24  mandana
-- interface change to accomodate 4-pole filter
--
-- Revision 1.10  2006/02/15 21:40:57  mandana
-- registers can now be reset by either fltr_rst_i or initialize_window_i
--
-- Revision 1.9  2006/02/09 17:19:03  bburger
-- Bryce:  removed an inappropriate signal from the sensitivity list of a clocked process.
--
-- Revision 1.8  2005/12/12 23:50:25  mandana
-- added filter storage elements, updated for filter-related interfaces
--
-- Revision 1.7  2005/10/07 21:38:07  bburger
-- Bryce:  Added a port between fsfb_io_controller and wbs_frame_data to readout flux_counts
--
-- Revision 1.6  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.5  2004/12/07 19:41:42  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.4  2004/11/26 18:26:45  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.3  2004/11/09 01:12:52  anthonyk
-- Added lock mode enable output for fsfb_ctrl block.
-- Added generic lock_dat_left.
-- Updated the fsfb_processor block instantiation.
--
-- Revision 1.2  2004/10/25 18:02:15  anthonyk
-- Changed input port name num_rows_sub1 to num_rows_sub1_i
--
-- Revision 1.1  2004/10/22 22:18:36  anthonyk
-- Initial release
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
use work.readout_card_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity fsfb_calc is
   generic (
      start_val                 : integer := FSFB_QUEUE_INIT_VAL;                               -- value read from the queue when initialize_window_i is asserted
      lock_dat_lsb              : integer := LOCK_LSB_POS;                                      -- least significant bit position of lock mode data output
      filter_lock_dat_lsb       : integer := FILTER_LOCK_LSB_POS                                -- lsb position of the pidz results fed as input to the filter
      );

   port ( 
      -- global signals
      rst_i                      : in     std_logic;                                             -- global reset
      clk_50_i                   : in     std_logic;                                             -- global clock
       
      -- control/interface signals from upstream coadd block
      coadd_done_i               : in     std_logic;                                             -- done signal issued by coadd block to indicate coadd data valid (one-clk period pulse)
      current_coadd_dat_i        : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current coadded value 
      current_diff_dat_i         : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current difference
      current_integral_dat_i     : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current integral
     
      -- control signals from frame timing block
      restart_frame_aligned_i    : in     std_logic;                                             -- start of frame signal
      restart_frame_1row_post_i  : in     std_logic;                                             -- start of frame signal (1 row behind of actual frame start)
      row_switch_i               : in     std_logic;                                             -- row switch signal to indicate next clock cycle is the beginning of new row
      initialize_window_i        : in     std_logic;                                             -- frame window at which all values read equal to fixed preset parameter
      num_rows_sub1_i            : in     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
      fltr_rst_i                 : in     std_logic;                                             -- reset internal registers (wn) of the filter
      
      -- control signals from configuration registers
      servo_mode_i               : in     std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     -- servo mode selection 
      ramp_step_size_i           : in     std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          -- ramp step increments/decrements
      ramp_amp_i                 : in     std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           -- ramp peak amplitude
      const_val_i                : in     std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          -- fs feedback constant value
      num_ramp_frame_cycles_i    : in     std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);           -- number of frame cycle ramp remained level 
      
      -- PIDZ coefficient queue interface
      p_addr_o                   : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);   -- coefficient queue address/data inputs/outputs 
      p_dat_i                    : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- read-only operations
      i_addr_o                   : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
      i_dat_i                    : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      d_addr_o                   : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
      d_dat_i                    : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_o         : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
      flux_quanta_dat_i          : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);

      filter_coeff0_i            : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff1_i            : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff2_i            : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff3_i            : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff4_i            : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff5_i            : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      
      -- first stage feedback queue (dedicated wishbone slave interface)
      fsfb_ws_addr_i             : in     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
      fsfb_ws_dat_o              : out    std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
      flux_cnt_ws_dat_o          : out    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      
      -- first stage feedback filter queue (dedicated wishbone slave interface)
      fsfb_ws_fltr_addr_i        : in     std_logic_vector(FLTR_QUEUE_ADDR_WIDTH-1 downto 0);    -- fsfb filter queue 
      fsfb_ws_fltr_dat_o         : out    std_logic_vector(WB_DATA_WIDTH-1 downto 0);    -- read-only operations
       
      -- first stage feedback queue (shared filter interface)
      fsfb_fltr_dat_rdy_o        : out    std_logic;                                             -- fs feedback queue current data ready 
      fsfb_fltr_dat_o            : out    std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 
            
      -- control/interface signals from first stage feedback correction block
      num_flux_quanta_pres_rdy_i : in     std_logic;                                             -- flux quanta present count ready
      num_flux_quanta_pres_i     : in     std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta present count    
      
      -- first stage feedback queue (dedicated first stage feedback correction interface)
      fsfb_ctrl_dat_rdy_o        : out    std_logic;                                             -- fs feedback queue previous data ready
      fsfb_ctrl_dat_o            : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue previous data
      
      -- interface signals to first stage feedback correction block
      num_flux_quanta_prev_o     : out    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta previous count        
      fsfb_ctrl_lock_en_o        : out    std_logic;                                             -- control lock data mode enable (used by fsfb_ctrl as well)
      flux_quanta_o              : out    std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0)    -- flux quanta value (formerly know as coeff z)      
  );


end fsfb_calc;

architecture struct of fsfb_calc is

   -- internal signal declarations   
   signal fsfb_proc_fltr_update_o     : std_logic;                                              -- filter data queue update
   signal fsfb_proc_fltr_dat_o        : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);      -- filter data to the queue
   signal fsfb_proc_update_o          : std_logic;                                              -- current first stage feedback data queue update
   signal fsfb_proc_dat_o             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- current first stage feedback data to be updated to the queue
   signal previous_fsfb_dat_rdy_o     : std_logic;                                              -- previous first stage feedback data ready
   signal previous_fsfb_dat_o         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- previous first stage feedback data read from the queue
   signal ramp_update_new_o           : std_logic;                                              -- enable to update ramp data latch content
   signal initialize_window_ext_o     : std_logic;                                              -- window at which the processor output for ramp mode is zeroed                   
   
   -- filter related signals
   signal fsfb_fltr_wr_data_o         : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);     -- write data to the fsfb filtered queue 
   
   -- Increased the width of the addresses by 1 to make filtered data available on demand
   signal fsfb_fltr_wr_addr_o         : std_logic_vector(FLTR_QUEUE_ADDR_WIDTH downto 0);     -- write address to the fsfb filtered queue 
   signal fsfb_fltr_rd_addr_o         : std_logic_vector(FLTR_QUEUE_ADDR_WIDTH downto 0);     -- read address to the fsfb filter queue 
   
   signal fsfb_fltr_wr_en_o           : std_logic;                                              -- write enable to the fsfb filter queue
   signal fsfb_fltr_rd_data_i         : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);     -- read data from the fsfb filter queue
   signal wn_addr_o                   : std_logic_vector(FLTR_QUEUE_ADDR_WIDTH-1 downto 0);     -- address for wn set of filter registers
   signal wn12_dat                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);          -- 1st biquad: filter wn2 result (wn delayed by 2 sample)
   signal wn11_dat                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);          -- 1st biquad: filter wn1 result (wn delayed by 1 sample)
   signal wn10_dat                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);          -- 1st biquad: filter wn result   
   signal wn22_dat                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);          -- 2nd biquad: filter wn2 result (wn delayed by 2 sample)
   signal wn21_dat                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);          -- 2nd biquad: filter wn1 result (wn delayed by 1 sample)
   signal wn20_dat                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);          -- 2nd biquad: filter wn result      
   signal fltr_rst                    : std_logic;                                              -- reset filter internal registers
   
--   signal row1_fltr_data              : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);     -- temporary for debug to store row1 data

   signal fsfb_queue_wr_data_o        : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- write data to the fsfb data queue (bank 0, 1)
   signal fsfb_queue_wr_addr_o        : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- write address to the fsfb data queue (bank 0, 1)
   signal fsfb_queue_rd_addra_o       : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port a) to the fsfb data queue (bank 0, 1)            
   signal fsfb_queue_rd_addrb_o       : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port b) to the fsfb data queue (bank 0, 1)
   signal fsfb_queue_wr_en_bank0_o    : std_logic;                                              -- write enable to the fsfb data queue (bank 0)
   signal fsfb_queue_wr_en_bank1_o    : std_logic;                                              -- write enable to the fsfb data queue (bank 1)
   signal fsfb_queue_rd_dataa_bank0_i : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port a) from the fsfb data queue (bank 0)
   signal fsfb_queue_rd_dataa_bank1_i : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port a) from the fsfb data queue (bank 1)
   signal fsfb_queue_rd_datab_bank0_i : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port b) from the fsfb data queue (bank 0)
   signal fsfb_queue_rd_datab_bank1_i : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port b) from the fsfb data queue (bank 1)
   
   signal flux_cnt_queue_wr_data_o        : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- write data to the fsfb quanta cnt queue (bank 0, 1)
   signal flux_cnt_queue_wr_addr_o        : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- write address to the fsfb quanta cnt queue (bank 0, 1)
   signal flux_cnt_queue_rd_addra_o       : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port a) to the fsfb quanta cnt queue (bank 0, 1)            
   signal flux_cnt_queue_rd_addrb_o       : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port b) to the fsfb quanta cnt queue (bank 0, 1)
   signal flux_cnt_queue_wr_en_bank0_o    : std_logic;                                              -- write enable to the fsfb quanta cnt queue (bank 0)
   signal flux_cnt_queue_wr_en_bank1_o    : std_logic;                                              -- write enable to the fsfb quanta cnt queue (bank 1)
   signal flux_cnt_queue_rd_dataa_bank0_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port a) from the fsfb quanta cnt queue (bank 0)
   signal flux_cnt_queue_rd_dataa_bank1_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port a) from the fsfb quanta cnt queue (bank 1)
   signal flux_cnt_queue_rd_datab_bank0_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port b) from the fsfb quanta cnt queue (bank 0)
   signal flux_cnt_queue_rd_datab_bank1_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port b) from the fsfb quanta cnt queue (bank 1)

begin
  
   -- first stage feedback i/o controller block
   -- this block manages all the input/outputs to/from first stage feedback queues
   i_fsfb_io_controller : fsfb_io_controller
      generic map (
         start_val                            => start_val
      )
      port map (
         rst_i                        => rst_i,
         clk_50_i                     => clk_50_i,
         restart_frame_aligned_i      => restart_frame_aligned_i,
         restart_frame_1row_post_i    => restart_frame_1row_post_i,
         row_switch_i                 => row_switch_i,
         initialize_window_i          => initialize_window_i,
         num_ramp_frame_cycles_i      => num_ramp_frame_cycles_i,
         num_flux_quanta_pres_rdy_i   => num_flux_quanta_pres_rdy_i,
         num_flux_quanta_pres_i       => num_flux_quanta_pres_i,
         fsfb_proc_fltr_update_i      => fsfb_proc_fltr_update_o,
         fsfb_proc_fltr_dat_i         => fsfb_proc_fltr_dat_o,
         fsfb_proc_update_i           => fsfb_proc_update_o,
         fsfb_proc_dat_i              => fsfb_proc_dat_o,
         fsfb_ws_fltr_addr_i          => fsfb_ws_fltr_addr_i,
         fsfb_ws_fltr_dat_o           => fsfb_ws_fltr_dat_o,
         fsfb_ws_addr_i               => fsfb_ws_addr_i,
         fsfb_ws_dat_o                => fsfb_ws_dat_o,
         flux_cnt_ws_dat_o            => flux_cnt_ws_dat_o,
         fsfb_fltr_dat_rdy_o          => fsfb_fltr_dat_rdy_o,
         fsfb_fltr_dat_o              => fsfb_fltr_dat_o,
         fsfb_ctrl_dat_rdy_o          => fsfb_ctrl_dat_rdy_o,
         fsfb_ctrl_dat_o              => fsfb_ctrl_dat_o,
         num_flux_quanta_prev_o       => num_flux_quanta_prev_o,
         p_addr_o                     => p_addr_o,
         i_addr_o                     => i_addr_o,
         d_addr_o                     => d_addr_o,
         wn_addr_o                    => wn_addr_o,
         flux_quanta_addr_o           => flux_quanta_addr_o,
         ramp_update_new_o            => ramp_update_new_o,
         initialize_window_ext_o      => initialize_window_ext_o,
         previous_fsfb_dat_rdy_o      => previous_fsfb_dat_rdy_o,
         previous_fsfb_dat_o          => previous_fsfb_dat_o,
         fsfb_fltr_wr_data_o          => fsfb_fltr_wr_data_o,
         fsfb_fltr_wr_addr_o          => fsfb_fltr_wr_addr_o,
         fsfb_fltr_rd_addr_o          => fsfb_fltr_rd_addr_o,            
         fsfb_fltr_wr_en_o            => fsfb_fltr_wr_en_o,
         fsfb_fltr_rd_data_i          => fsfb_fltr_rd_data_i,         
         fsfb_queue_wr_data_o         => fsfb_queue_wr_data_o,
         fsfb_queue_wr_addr_o         => fsfb_queue_wr_addr_o,
         fsfb_queue_rd_addra_o        => fsfb_queue_rd_addra_o,            
         fsfb_queue_rd_addrb_o        => fsfb_queue_rd_addrb_o,
         fsfb_queue_wr_en_bank0_o     => fsfb_queue_wr_en_bank0_o,
         fsfb_queue_wr_en_bank1_o     => fsfb_queue_wr_en_bank1_o,
         fsfb_queue_rd_dataa_bank0_i  => fsfb_queue_rd_dataa_bank0_i, 
         fsfb_queue_rd_dataa_bank1_i  => fsfb_queue_rd_dataa_bank1_i,
         fsfb_queue_rd_datab_bank0_i  => fsfb_queue_rd_datab_bank0_i,
         fsfb_queue_rd_datab_bank1_i  => fsfb_queue_rd_datab_bank1_i,
         flux_cnt_queue_wr_data_o     => flux_cnt_queue_wr_data_o,
         flux_cnt_queue_wr_addr_o     => flux_cnt_queue_wr_addr_o,
         flux_cnt_queue_rd_addra_o    => flux_cnt_queue_rd_addra_o,
         flux_cnt_queue_rd_addrb_o    => flux_cnt_queue_rd_addrb_o,
         flux_cnt_queue_wr_en_bank0_o => flux_cnt_queue_wr_en_bank0_o,
         flux_cnt_queue_wr_en_bank1_o => flux_cnt_queue_wr_en_bank1_o,
         flux_cnt_queue_rd_dataa_bank0_i => flux_cnt_queue_rd_dataa_bank0_i,
         flux_cnt_queue_rd_dataa_bank1_i => flux_cnt_queue_rd_dataa_bank1_i,
         flux_cnt_queue_rd_datab_bank0_i => flux_cnt_queue_rd_datab_bank0_i,
         flux_cnt_queue_rd_datab_bank1_i => flux_cnt_queue_rd_datab_bank1_i                  
      );
          
   -- Flux Quanta Unit output is now configured with the z coefficient
   flux_quanta_o <= flux_quanta_dat_i;
   
         
   -- first stage feedback processor block
   -- this block contains the ALU circuitry including multipliers and adders
   i_fsfb_processor : fsfb_processor
      generic map (
         lock_dat_lsb                 => lock_dat_lsb,
         filter_lock_dat_lsb          => filter_lock_dat_lsb
      )
      port map (
         rst_i                        => rst_i,
         clk_50_i                     => clk_50_i,
         coadd_done_i                 => coadd_done_i,
         current_coadd_dat_i          => current_coadd_dat_i,
         current_diff_dat_i           => current_diff_dat_i,
         current_integral_dat_i       => current_integral_dat_i,
         ramp_update_new_i            => ramp_update_new_o,
         initialize_window_ext_i      => initialize_window_ext_o,
         previous_fsfb_dat_rdy_i      => previous_fsfb_dat_rdy_o,
         previous_fsfb_dat_i          => previous_fsfb_dat_o,
         servo_mode_i                 => servo_mode_i, 
         ramp_step_size_i             => ramp_step_size_i,
         ramp_amp_i                   => ramp_amp_i,
         const_val_i                  => const_val_i,
         p_dat_i                      => p_dat_i,
         i_dat_i                      => i_dat_i,
         d_dat_i                      => d_dat_i,
         filter_coeff0_i              => filter_coeff0_i(FILTER_COEF_WIDTH-1 downto 0),
         filter_coeff1_i              => filter_coeff1_i(FILTER_COEF_WIDTH-1 downto 0),
         filter_coeff2_i              => filter_coeff2_i(FILTER_COEF_WIDTH-1 downto 0),
         filter_coeff3_i              => filter_coeff3_i(FILTER_COEF_WIDTH-1 downto 0),
         filter_coeff4_i              => filter_coeff4_i(FILTER_COEF_WIDTH-1 downto 0),
         filter_coeff5_i              => filter_coeff5_i(FILTER_COEF_WIDTH-1 downto 0),

         wn11_dat_i                   => wn11_dat,
         wn12_dat_i                   => wn12_dat,
         wn10_dat_o                   => wn10_dat,
         wn21_dat_i                   => wn21_dat,
         wn22_dat_i                   => wn22_dat,
         wn20_dat_o                   => wn20_dat,         
         fsfb_proc_update_o           => fsfb_proc_update_o,
         fsfb_proc_dat_o              => fsfb_proc_dat_o,
         fsfb_proc_fltr_update_o      => fsfb_proc_fltr_update_o,
         fsfb_proc_fltr_dat_o         => fsfb_proc_fltr_dat_o,
         fsfb_proc_lock_en_o          => fsfb_ctrl_lock_en_o
      ); 
     
     
   -- first stage feedback queues
   -- Bank 0 (even)
   -- Queue is 25-bit wide:  24 (ramp +/-); 23:0 (actual fsfb data)
   i_fsfb_queue_bank0 : ram_40x64
      port map (
         data                         => fsfb_queue_wr_data_o,
         wraddress                    => fsfb_queue_wr_addr_o,
         rdaddress_a                  => fsfb_queue_rd_addra_o,
         rdaddress_b                  => fsfb_queue_rd_addrb_o,
         wren                         => fsfb_queue_wr_en_bank0_o,
         clock                        => clk_50_i,
         qa                           => fsfb_queue_rd_dataa_bank0_i,
         qb                           => fsfb_queue_rd_datab_bank0_i
      );   
    
   -- Bank 1 (odd)
   -- Queue is 25-bit wide:  24 (ramp +/-); 23:0 (actual fsfb data)   
   i_fsfb_queue_bank1 : ram_40x64
      port map (
         data                         => fsfb_queue_wr_data_o,
         wraddress                    => fsfb_queue_wr_addr_o,
         rdaddress_a                  => fsfb_queue_rd_addra_o,
         rdaddress_b                  => fsfb_queue_rd_addrb_o,
         wren                         => fsfb_queue_wr_en_bank1_o,
         clock                        => clk_50_i,
         qa                           => fsfb_queue_rd_dataa_bank1_i,
         qb                           => fsfb_queue_rd_datab_bank1_i
      );         
   
   -- filter output storage      
   -- Queue is 32-bit wide
   i_fsfb_filter_storage0 : fsfb_filter_storage
      port map (
         data                         => fsfb_fltr_wr_data_o,
         wraddress                    => fsfb_fltr_wr_addr_o,
         rdaddress                    => fsfb_fltr_rd_addr_o,
         wren                         => fsfb_fltr_wr_en_o,
         clock                        => clk_50_i,
         q                            => fsfb_fltr_rd_data_i
      );   
   
   -- Try to make this part of the other queue, and switch between the first and second halves with msb for the address.
--   i_fsfb_filter_storage1 : fsfb_filter_storage
--      port map (
--         data                         => ,
--         wraddress                    => ,
--         rdaddress                    => ,
--         wren                         => ,
--         clock                        => clk_50_i,
--         q                            => 
--      );   

   -- filter wn storage (set of registers)
   i_fsfb_fltr_regs: fsfb_fltr_regs
      port map (
         rst_i                       => rst_i,
         clk_50_i                    => clk_50_i,
         fltr_rst_i                  => fltr_rst,
         addr_i                      => wn_addr_o,
         wn12_o                      => wn12_dat,
         wn11_o                      => wn11_dat,
         wn10_i                      => wn10_dat,
         wn22_o                      => wn22_dat,
         wn21_o                      => wn21_dat,
         wn20_i                      => wn20_dat,         
         wren_i                      => fsfb_fltr_wr_en_o
      ); 

   -- reset wn registers when either of fltr_rst or initialize_window are asserted
   fltr_rst <= fltr_rst_i or initialize_window_i;
   

   -- flux quanta counter queues
   -- Bank 0 (even)
   -- Queue is 8-bit wide: 2's complement -- 7 (sign); 6:0 (magnitude) 
   i_flux_cnt_queue_bank0 : ram_8x64
      port map (
         data                         => flux_cnt_queue_wr_data_o,
         wraddress                    => flux_cnt_queue_wr_addr_o,
         rdaddress_a                  => flux_cnt_queue_rd_addra_o,
         rdaddress_b                  => flux_cnt_queue_rd_addrb_o,
         wren                         => flux_cnt_queue_wr_en_bank0_o,
         clock                        => clk_50_i,
         qa                           => flux_cnt_queue_rd_dataa_bank0_i,
         qb                           => flux_cnt_queue_rd_datab_bank0_i
      );   
      
   -- Bank 1 (odd)
   -- Queue is 8-bit wide: 2's complement -- 7 (sign); 6:0 (magnitude) 
   i_flux_cnt_queue_bank1 : ram_8x64
      port map (
         data                         => flux_cnt_queue_wr_data_o,
         wraddress                    => flux_cnt_queue_wr_addr_o,
         rdaddress_a                  => flux_cnt_queue_rd_addra_o,
         rdaddress_b                  => flux_cnt_queue_rd_addrb_o,
         wren                         => flux_cnt_queue_wr_en_bank1_o,
         clock                        => clk_50_i,
         qa                           => flux_cnt_queue_rd_dataa_bank1_i,
         qb                           => flux_cnt_queue_rd_datab_bank1_i
      );   
    
   
   
end struct;
