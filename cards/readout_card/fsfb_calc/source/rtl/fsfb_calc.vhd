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
      lock_dat_left             : integer := MOST_SIG_LOCK_POS                                  -- most significant bit position of lock mode data output
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
      
      -- first stage feedback queue (dedicated wishbone slave interface)
      fsfb_ws_addr_i             : in     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
      fsfb_ws_dat_o              : out    std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
      flux_cnt_ws_dat_o          : out    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
 
      -- first stage feedback queue (shared filter interface)
      fsfb_fltr_dat_rdy_o        : out    std_logic;                                             -- fs feedback queue current data ready 
      fsfb_fltr_dat_o            : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 

      -- control/interface signals from first stage feedback correction block
      num_flux_quanta_pres_rdy_i : in     std_logic;                                             -- flux quanta present count ready
      num_flux_quanta_pres_i     : in     std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta present count    
      
      -- first stage feedback queue (dedicated first stage feedback correction interface)
      fsfb_ctrl_dat_rdy_o        : out    std_logic;                                             -- fs feedback queue previous data ready
      fsfb_ctrl_dat_o            : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue previous data
      
      -- interface signals to first stage feedback correction block
      num_flux_quanta_prev_o     : out    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta previous count        
      fsfb_ctrl_lock_en_o        : out    std_logic;                                             -- control lock data mode enable (used by fsfb_ctrl as well)
      flux_jumping_en_i          : in     std_logic;
      flux_quanta_o              : out    std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0)    -- flux quanta value (formerly know as coeff z)
      
  );


end fsfb_calc;

architecture struct of fsfb_calc is

   -- internal signal declarations
   
   signal fsfb_proc_update_o                   : std_logic;                                              -- current first stage feedback data queue update
   signal fsfb_proc_dat_o                      : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- current first stage feedback data to be updated to the queue
   signal previous_fsfb_dat_rdy_o              : std_logic;                                              -- previous first stage feedback data ready
   signal previous_fsfb_dat_o                  : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- previous first stage feedback data read from the queue
   signal ramp_update_new_o                    : std_logic;                                              -- enable to update ramp data latch content
   signal initialize_window_ext_o              : std_logic;                                              -- window at which the processor output for ramp mode is zeroed                   

   signal fsfb_queue_wr_data_o                 : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- write data to the fsfb data queue (bank 0, 1)
   signal fsfb_queue_wr_addr_o                 : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- write address to the fsfb data queue (bank 0, 1)
   signal fsfb_queue_rd_addra_o                : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port a) to the fsfb data queue (bank 0, 1)            
   signal fsfb_queue_rd_addrb_o                : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port b) to the fsfb data queue (bank 0, 1)
   signal fsfb_queue_wr_en_bank0_o             : std_logic;                                              -- write enable to the fsfb data queue (bank 0)
   signal fsfb_queue_wr_en_bank1_o             : std_logic;                                              -- write enable to the fsfb data queue (bank 1)
   signal fsfb_queue_rd_dataa_bank0_i          : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port a) from the fsfb data queue (bank 0)
   signal fsfb_queue_rd_dataa_bank1_i          : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port a) from the fsfb data queue (bank 1)
   signal fsfb_queue_rd_datab_bank0_i          : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port b) from the fsfb data queue (bank 0)
   signal fsfb_queue_rd_datab_bank1_i          : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       -- read data (port b) from the fsfb data queue (bank 1)
   
   signal fsfb_flux_cnt_queue_wr_data_o        : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- write data to the fsfb quanta cnt queue (bank 0, 1)
   signal fsfb_flux_cnt_queue_wr_addr_o        : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- write address to the fsfb quanta cnt queue (bank 0, 1)
   signal fsfb_flux_cnt_queue_rd_addra_o       : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port a) to the fsfb quanta cnt queue (bank 0, 1)            
   signal fsfb_flux_cnt_queue_rd_addrb_o       : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     -- read address (port b) to the fsfb quanta cnt queue (bank 0, 1)
   signal fsfb_flux_cnt_queue_wr_en_bank0_o    : std_logic;                                              -- write enable to the fsfb quanta cnt queue (bank 0)
   signal fsfb_flux_cnt_queue_wr_en_bank1_o    : std_logic;                                              -- write enable to the fsfb quanta cnt queue (bank 1)
   signal fsfb_flux_cnt_queue_rd_dataa_bank0_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port a) from the fsfb quanta cnt queue (bank 0)
   signal fsfb_flux_cnt_queue_rd_dataa_bank1_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port a) from the fsfb quanta cnt queue (bank 1)
   signal fsfb_flux_cnt_queue_rd_datab_bank0_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port b) from the fsfb quanta cnt queue (bank 0)
   signal fsfb_flux_cnt_queue_rd_datab_bank1_i : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     -- read data (port b) from the fsfb quanta cnt queue (bank 1)



begin
  
   -- first stage feedback i/o controller block
   -- this block manages all the input/outputs to/from first stage feedback queues
   i_fsfb_io_controller : fsfb_io_controller
      generic map (
         start_val                            => start_val
      )
      port map (
         rst_i                                => rst_i,
         clk_50_i                             => clk_50_i,
         restart_frame_aligned_i              => restart_frame_aligned_i,
         restart_frame_1row_post_i            => restart_frame_1row_post_i,
         row_switch_i                         => row_switch_i,
         initialize_window_i                  => initialize_window_i,
         num_ramp_frame_cycles_i              => num_ramp_frame_cycles_i,
         num_flux_quanta_pres_rdy_i           => num_flux_quanta_pres_rdy_i,
         num_flux_quanta_pres_i               => num_flux_quanta_pres_i,
         fsfb_proc_update_i                   => fsfb_proc_update_o,
         fsfb_proc_dat_i                      => fsfb_proc_dat_o,
         fsfb_ws_addr_i                       => fsfb_ws_addr_i,
         fsfb_ws_dat_o                        => fsfb_ws_dat_o,
         flux_cnt_ws_dat_o                    => flux_cnt_ws_dat_o,
         fsfb_fltr_dat_rdy_o                  => fsfb_fltr_dat_rdy_o,
         fsfb_fltr_dat_o                      => fsfb_fltr_dat_o,
         fsfb_ctrl_dat_rdy_o                  => fsfb_ctrl_dat_rdy_o,
         fsfb_ctrl_dat_o                      => fsfb_ctrl_dat_o,
         num_flux_quanta_prev_o               => num_flux_quanta_prev_o,
         p_addr_o                             => p_addr_o,
         i_addr_o                             => i_addr_o,
         d_addr_o                             => d_addr_o,
         flux_quanta_addr_o                   => flux_quanta_addr_o,
         ramp_update_new_o                    => ramp_update_new_o,
         initialize_window_ext_o              => initialize_window_ext_o,
         previous_fsfb_dat_rdy_o              => previous_fsfb_dat_rdy_o,
         previous_fsfb_dat_o                  => previous_fsfb_dat_o,
         fsfb_queue_wr_data_o                 => fsfb_queue_wr_data_o,
         fsfb_queue_wr_addr_o                 => fsfb_queue_wr_addr_o,
         fsfb_queue_rd_addra_o                => fsfb_queue_rd_addra_o,            
         fsfb_queue_rd_addrb_o                => fsfb_queue_rd_addrb_o,
         fsfb_queue_wr_en_bank0_o             => fsfb_queue_wr_en_bank0_o,
         fsfb_queue_wr_en_bank1_o             => fsfb_queue_wr_en_bank1_o,
         fsfb_queue_rd_dataa_bank0_i          => fsfb_queue_rd_dataa_bank0_i, 
         fsfb_queue_rd_dataa_bank1_i          => fsfb_queue_rd_dataa_bank1_i,
         fsfb_queue_rd_datab_bank0_i          => fsfb_queue_rd_datab_bank0_i,
         fsfb_queue_rd_datab_bank1_i          => fsfb_queue_rd_datab_bank1_i,
         fsfb_flux_cnt_queue_wr_data_o        => fsfb_flux_cnt_queue_wr_data_o,
         fsfb_flux_cnt_queue_wr_addr_o        => fsfb_flux_cnt_queue_wr_addr_o,
         fsfb_flux_cnt_queue_rd_addra_o       => fsfb_flux_cnt_queue_rd_addra_o,
         fsfb_flux_cnt_queue_rd_addrb_o       => fsfb_flux_cnt_queue_rd_addrb_o,
         fsfb_flux_cnt_queue_wr_en_bank0_o    => fsfb_flux_cnt_queue_wr_en_bank0_o,
         fsfb_flux_cnt_queue_wr_en_bank1_o    => fsfb_flux_cnt_queue_wr_en_bank1_o,
         fsfb_flux_cnt_queue_rd_dataa_bank0_i => fsfb_flux_cnt_queue_rd_dataa_bank0_i,
         fsfb_flux_cnt_queue_rd_dataa_bank1_i => fsfb_flux_cnt_queue_rd_dataa_bank1_i,
         fsfb_flux_cnt_queue_rd_datab_bank0_i => fsfb_flux_cnt_queue_rd_datab_bank0_i,
         fsfb_flux_cnt_queue_rd_datab_bank1_i => fsfb_flux_cnt_queue_rd_datab_bank1_i                  
      );
          
   -- Flux Quanta Unit output is now configured with the z coefficient
   flux_quanta_o <= flux_quanta_dat_i;
   
         
   -- first stage feedback processor block
   -- this block contains the ALU circuitry including multipliers and adders
   i_fsfb_processor : fsfb_processor
      generic map (
         lock_dat_left                => lock_dat_left
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
--         flux_quanta_dat_i            => flux_quanta_dat_i,
         fsfb_proc_update_o           => fsfb_proc_update_o,
         fsfb_proc_dat_o              => fsfb_proc_dat_o,
         flux_jumping_en_i            => flux_jumping_en_i,
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
   
   
   -- flux quanta counter queues
   -- Bank 0 (even)
   -- Queue is 8-bit wide: 2's complement -- 7 (sign); 6:0 (magnitude) 
   i_fsfb_flux_cnt_queue_bank0 : ram_8x64
      port map (
         data                         => fsfb_flux_cnt_queue_wr_data_o,
         wraddress                    => fsfb_flux_cnt_queue_wr_addr_o,
         rdaddress_a                  => fsfb_flux_cnt_queue_rd_addra_o,
         rdaddress_b                  => fsfb_flux_cnt_queue_rd_addrb_o,
         wren                         => fsfb_flux_cnt_queue_wr_en_bank0_o,
         clock                        => clk_50_i,
         qa                           => fsfb_flux_cnt_queue_rd_dataa_bank0_i,
         qb                           => fsfb_flux_cnt_queue_rd_datab_bank0_i
      );   
      
   -- Bank 1 (odd)
   -- Queue is 8-bit wide: 2's complement -- 7 (sign); 6:0 (magnitude) 
   i_fsfb_flux_cnt_queue_bank1 : ram_8x64
      port map (
         data                         => fsfb_flux_cnt_queue_wr_data_o,
         wraddress                    => fsfb_flux_cnt_queue_wr_addr_o,
         rdaddress_a                  => fsfb_flux_cnt_queue_rd_addra_o,
         rdaddress_b                  => fsfb_flux_cnt_queue_rd_addrb_o,
         wren                         => fsfb_flux_cnt_queue_wr_en_bank1_o,
         clock                        => clk_50_i,
         qa                           => fsfb_flux_cnt_queue_rd_dataa_bank1_i,
         qb                           => fsfb_flux_cnt_queue_rd_datab_bank1_i
      );   
    
   
   
end struct;
