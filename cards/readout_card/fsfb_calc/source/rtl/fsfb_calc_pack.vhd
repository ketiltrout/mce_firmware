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
-- fsfb_calc_pack.vhd
--
-- Project:   SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- First stage feedback calculation firmware package
--
-- Contains definitions of components and constants specific to fsfb_calc block
--
--
-- Revision history:
-- 
-- $Log: fsfb_calc_pack.vhd,v $
-- Revision 1.18  2008/10/03 00:32:14  mandana
-- BB: Removed the z_dat_i port in fsfb_processor.vhd and fsfb_calc_pack.vhd to the fsfb_proc_pidz block, in an effort to make it clearer within that block that the z-term is always = 0.
--
-- Revision 1.17  2008/07/08 22:16:47  mandana
-- added comments for filter coefficients, no code change.
--
-- Revision 1.16  2007/03/21 17:26:46  mandana
-- updated the width of ouput data port on fsfb_proc_ramp
--
-- Revision 1.15  2007/03/07 21:09:57  mandana
-- filter_input_width is now used to determine how many bits of pid calc results are passed to the filter
--
-- Revision 1.14  2006/08/10 21:30:42  mandana
-- *** empty log message ***
--
-- Revision 1.13  2006/07/28 17:41:52  mandana
-- introduced FILTER_GAIN_WIDTH parameter to divide by 32 between 2 filter biquads
--
-- Revision 1.12  2006/07/20 18:49:56  mandana
-- merged from ACT_100Hz_cutoff branch which includes 4-pole filter
-- changed FILTER_LOCK_LSB_POS to 12
--
-- Revision 1.11.4.2  2006/03/14 22:46:00  mandana
-- upgraded 2-pole Butterworth LPF to 4-pole, coefficients set for fc/fs=100/12195
--
-- Revision 1.11.4.1  2006/02/17 21:56:02  mandana
-- Filter coefficients are set for 100Hz cutoff at 12195Hz Sampling rate
--
-- Revision 1.11  2006/02/15 21:43:35  mandana
-- changed initialize_window_i port to fltr_rst_i port on fltr_regs
-- changed filter_lock_lsb_pos from 0 to 10
--
-- Revision 1.10  2006/02/14 22:59:20  bburger
-- Bryce:  Commital for an experimental tag rc_14feb2006_filter10_and_fj_fix_old_dispatch
-- This file actually does have the filter window set to 10, unlike the last commital.
--
-- Revision 1.9  2006/02/08 21:22:06  bburger
-- Mandana: changed FILTER_LOCK_LSB_POS from 0 to 10
--
-- Revision 1.8  2005/12/14 18:20:36  mandana
-- added 2-pole LPF filter functionality
--
-- Revision 1.7  2005/11/28 19:11:29  bburger
-- Bryce:  increased the bus width for fb_const, ramp_dly, ramp_amp and ramp_step from 14 bits to 32 bits, to use them for flux-jumping testing
--
-- Revision 1.6  2005/10/07 21:38:07  bburger
-- Bryce:  Added a port between fsfb_io_controller and wbs_frame_data to readout flux_counts
--
-- Revision 1.5  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.4  2004/12/07 19:41:42  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.3  2004/11/26 18:26:45  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/11/09 01:10:08  anthonyk
-- Update package to reflect newly added constant, 66 bit adder
-- component and modified fsfb_processor definitions.
--
-- Revision 1.1  2004/10/22 22:18:36  anthonyk
-- Initial release
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.readout_card_pack.all;
use work.flux_loop_pack.all;
use work.flux_loop_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

package fsfb_calc_pack is

   ---------------------------------------------------------------------------------
   -- First stage feedback calculator block constants
   ---------------------------------------------------------------------------------
   constant FSFB_QUEUE_INIT_VAL    : integer := 0;                    -- initialized read value from the first stage feedback queue
   constant LOCK_MSB_POS           : integer := 37;                   -- most significant bit position of lock mode data output
   -- constant MOST_SIG_LOCK_POS      : integer := 22;                   -- most significant bit position of lock mode data output
   
   ---------------------------------------------------------------------------------
   -- First stage feedback filter block constants
   ---------------------------------------------------------------------------------

   constant FILTER_LOCK_LSB_POS    : integer := 12;            -- scaling factor for the input to the filter chain
                                                               -- a sliding window of the 66b result is used as the filter input
   constant FILTER_SCALE_LSB       : integer := 1;
   constant FILTER_GAIN_WIDTH      : integer := 11;            -- 1/2^11 is the gain scaling between two filter stages.
 
   constant FILTER_INPUT_WIDTH     : integer := 18;            -- number of bits in the input NOT USED 
   constant FILTER_COEF_WIDTH      : integer := 15;            -- number of bits in the coefficient
   constant FILTER_DLY_WIDTH       : integer := 29;            -- number of bits for wn terms (refer to IIR direct form II)
   constant FILTER_OUTPUT_WIDTH    : integer := 32;            -- number of bits in the output
   constant FILTER_FEEDBACK_WIDTH  : integer := 2*FILTER_DLY_WIDTH+1; -- number of bits that results from b1*wn1+b2*wn2 calculations

   -- the interim results of the filter calculation are trimmed as follows
   constant FILTER_FB_L_BIT        : integer := FILTER_COEF_WIDTH-1;                 -- low bit 
   constant FILTER_FB_H_BIT        : integer := FILTER_FB_L_BIT+FILTER_DLY_WIDTH-1;     -- high bit
   
   -- The coefficients are chosen through Simulink FDAtool interface when a 4-pole Butterworth filter is chosen
   -- If I use coefficients generated by [a,b] = butter(2,50/20000); [SOS,G] = tf2sos(a,b)
   -- then the filter is not as robust. why!?
   -- SOS: Second-order sections
   --                                    SOS: a0 a1 a2 b0 b1                   b2
   -- for scuba2        fc/fs=50/20000,  SOS: 1  2  1  1  -1.976684937589464   0.97695361953638415
   -- for princeton act fc/fs=100/10000, SOS: 1  2  1  1  -1.9111970674260732  0.91497583480143374    
   -- for princeton act fc/fs=100/12195, SOS: 1  2  1  1  -1.9271665250923744  0.92972726807229988
   -- for princeton act fc/fs=100/12195, SOS: 1  2  1  1  -1.9587428340882587  0.96134553442399129 (1st biquad)       
   --                                         1  2  1  1  -1.9066292518523014  0.90916270571237567 (2nd biquad)       
   --                           Scale Values: 0.00065067508393319923                                       
   --                                         0.00063336346501859835       
   -- To convert to signed binary fractional, multiply the number by 2^14 and convert to hex. 
                                                                                         
   constant FILTER_B11_COEF         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) := "111110101011100"; -- SBF 1.14, 0x7D5C, -1.9587428340882587
                                                                                      --"111101001010001"; -- SBF 1.14, 0x7A51, -1.9111970674260732 
                                                                                      --"111111010000010"; -- SBF 1.14, 0x7e82, -1.976684937589464
                                                                                      --"11111101001010"; --SBF 1.13, 0x3f4a = 1.977786483(dec)
   

   constant FILTER_B12_COEF         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) := "011110110000110"; -- SBF 1.14, 0x3D86, 0.96134553442399129
                                                                                      --"011101010001110"; -- SBF 1.14, 0x3a8e, 0.91497583480143374   
                                                                                      --"011111010000110"; -- SBF 1.14, 0x3e86, 0.97695361953638415  
                                                                                      --"01111101001100"; --SBF 1.13, 0x1f4c = 0.97803050849

   constant FILTER_B21_COEF         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) := "111101000000110"; -- SBF 1.14, 0x7A06, -1.9066292518523014
   constant FILTER_B22_COEF         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) := "011101000101111"; -- SBF 1.14, 0x3A2F, 0.90916270571237567   
                                                                                       
   ---------------------------------------------------------------------------------
   -- First stage feedback input output controller component
   ---------------------------------------------------------------------------------
      
   component fsfb_io_controller is
      generic (
         start_val                            : integer := 0                                        
         );

      port (
         rst_i                       : in           std_logic;
         clk_50_i                    : in           std_logic;
         restart_frame_aligned_i     : in           std_logic;
         restart_frame_1row_post_i   : in           std_logic;
         row_switch_i                : in           std_logic;
         initialize_window_i         : in           std_logic;
         num_ramp_frame_cycles_i     : in           std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
         num_flux_quanta_pres_rdy_i  : in           std_logic;
         num_flux_quanta_pres_i      : in           std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
         fsfb_proc_fltr_update_i     : in           std_logic;                 
         fsfb_proc_fltr_dat_i        : in           std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0); 
         fsfb_proc_update_i          : in           std_logic;
         fsfb_proc_dat_i             : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
         fsfb_ws_fltr_addr_i         : in           std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
         fsfb_ws_fltr_dat_o          : out          std_logic_vector(WB_DATA_WIDTH-1 downto 0);      
         fsfb_ws_addr_i              : in           std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
         fsfb_ws_dat_o               : out          std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         flux_cnt_ws_dat_o           : out          std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
         fsfb_fltr_dat_rdy_o         : out          std_logic;
         fsfb_fltr_dat_o             : out          std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);
         fsfb_ctrl_dat_rdy_o         : out          std_logic;
         fsfb_ctrl_dat_o             : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
         num_flux_quanta_prev_o      : out          std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
         p_addr_o                    : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         i_addr_o                    : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         d_addr_o                    : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         wn_addr_o                   : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
         flux_quanta_addr_o          : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         ramp_update_new_o           : out          std_logic;
         initialize_window_ext_o     : out          std_logic;
         previous_fsfb_dat_rdy_o     : out          std_logic;
         previous_fsfb_dat_o         : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
         fsfb_fltr_wr_data_o         : out          std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);    
         fsfb_fltr_wr_addr_o         : out          std_logic_vector(FLTR_QUEUE_ADDR_WIDTH downto 0);  
         fsfb_fltr_rd_addr_o         : out          std_logic_vector(FLTR_QUEUE_ADDR_WIDTH downto 0);  
         fsfb_fltr_wr_en_o           : out          std_logic;                                           
         fsfb_fltr_rd_data_i         : in           std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);  
         fsfb_queue_wr_data_o        : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    
         fsfb_queue_wr_addr_o        : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  
         fsfb_queue_rd_addra_o       : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  
         fsfb_queue_rd_addrb_o       : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  
         fsfb_queue_wr_en_bank0_o    : out          std_logic;                                           
         fsfb_queue_wr_en_bank1_o    : out          std_logic;                                           
         fsfb_queue_rd_dataa_bank0_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    
         fsfb_queue_rd_dataa_bank1_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);     
         fsfb_queue_rd_datab_bank0_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    
         fsfb_queue_rd_datab_bank1_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
         flux_cnt_queue_wr_data_o        : out          std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     
         flux_cnt_queue_wr_addr_o        : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     
         flux_cnt_queue_rd_addra_o       : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);                 
         flux_cnt_queue_rd_addrb_o       : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     
         flux_cnt_queue_wr_en_bank0_o    : out          std_logic;                                              
         flux_cnt_queue_wr_en_bank1_o    : out          std_logic;                                              
         flux_cnt_queue_rd_dataa_bank0_i : in           std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     
         flux_cnt_queue_rd_dataa_bank1_i : in           std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     
         flux_cnt_queue_rd_datab_bank0_i : in           std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     
         flux_cnt_queue_rd_datab_bank1_i : in           std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0)       
      );
   end component fsfb_io_controller;
      
      
   ---------------------------------------------------------------------------------
   -- First stage feedback processor component
   ---------------------------------------------------------------------------------   
      
   component fsfb_processor is
      generic (
         lock_dat_left               : integer := 30;
         filter_lock_dat_lsb         : integer := 0
         );

      port (
         rst_i                       : in           std_logic;
         clk_50_i                    : in           std_logic;
         coadd_done_i                : in           std_logic;
         current_coadd_dat_i         : in           std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
         current_diff_dat_i          : in           std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
         current_integral_dat_i      : in           std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);
         ramp_update_new_i           : in           std_logic;
         initialize_window_ext_i     : in           std_logic;
         previous_fsfb_dat_rdy_i     : in           std_logic;                                             
         previous_fsfb_dat_i         : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);      
         servo_mode_i                : in           std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0); 
         ramp_step_size_i            : in           std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
         ramp_amp_i                  : in           std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
         const_val_i                 : in           std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
         p_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         i_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         d_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         wn12_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn11_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn10_dat_o                  : out          std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn22_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn21_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn20_dat_o                  : out          std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);         
         fsfb_proc_update_o          : out          std_logic;
         fsfb_proc_dat_o             : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
         fsfb_proc_fltr_update_o     : out          std_logic;                                             
         fsfb_proc_fltr_dat_o        : out          std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);        
         fsfb_proc_lock_en_o         : out          std_logic
      );  
   end component fsfb_processor;
   
   
   ---------------------------------------------------------------------------------
   -- First stage feedback processor subcomponent (lock mode)
   ---------------------------------------------------------------------------------
   
   component fsfb_proc_pidz is
      generic (
         filter_lock_dat_lsb        : integer := 0
      );
      port (
         rst_i                       : in           std_logic;                                            
         clk_50_i                    : in           std_logic;                                            
         coadd_done_i                : in           std_logic;                                            
         current_coadd_dat_i         : in           std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);  
         current_diff_dat_i          : in           std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);  
         current_integral_dat_i      : in           std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);  
         lock_mode_en_i              : in           std_logic;                                            
         p_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  
         i_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  
         d_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  
--         z_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  
         wn11_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn12_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);        
         wn10_dat_o                  : out          std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn21_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn22_dat_i                  : in           std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);        
         wn20_dat_o                  : out          std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);         
--         b1_dat_i                    : in           std_logic_vector(FLTR_COEFF_DATA_WIDTH-1 downto 0);   -- b1 coeefficient data width for 2-pole FIR filter
--         b0_dat_i                    : in           std_logic_vector(FLTR_COEFF_DATA_WIDTH-1 downto 0);   -- b0 coeefficient data width for 2-pole FIR filter         
         fsfb_proc_pidz_update_o     : out          std_logic;                                            
         fsfb_proc_pidz_sum_o        : out          std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);
         fsfb_proc_fltr_update_o     : out          std_logic;                                            
         fsfb_proc_fltr_sum_o        : out          std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0)
      );   
   end component fsfb_proc_pidz; 
   
   
   ---------------------------------------------------------------------------------
   -- First stage feedback processor subcomponent (ramp mode)
   ---------------------------------------------------------------------------------
   
   component fsfb_proc_ramp is
      port (
         rst_i                       : in            std_logic;                                            
         clk_50_i                    : in            std_logic; 
         previous_fsfb_dat_rdy_i     : in            std_logic;
         previous_fsfb_dat_i         : in            std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);                                             
         ramp_mode_en_i              : in            std_logic;                                            
         ramp_step_size_i            : in            std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);         
         ramp_amp_i                  : in            std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);          
         fsfb_proc_ramp_update_o     : out           std_logic;                                            
         fsfb_proc_ramp_dat_o        : out           std_logic_vector(RAMP_AMP_WIDTH downto 0)
      );
   end component fsfb_proc_ramp;

   ---------------------------------------------------------------------------------
   -- First stage feedback data queue component, generated by ALTERA megafunction
   ---------------------------------------------------------------------------------
   
   component ram_40x64 is
      port (
         data                        : in            std_logic_vector(39 DOWNTO 0);
         wraddress                   : in            std_logic_vector(5 DOWNTO 0);
         rdaddress_a                 : in            std_logic_vector(5 DOWNTO 0);
         rdaddress_b                 : in            std_logic_vector(5 DOWNTO 0);
         wren                        : in            std_logic;
         clock                       : in            std_logic;
         qa                          : out           std_logic_vector(39 DOWNTO 0);
         qb                          : out           std_logic_vector(39 DOWNTO 0)
      );
   end component;
    
   ---------------------------------------------------------------------------------------
   -- First stage flux quanta counter queue component, generated by ALTERA megafunction
   ---------------------------------------------------------------------------------------
   
  component ram_8x64
    port (
      data        : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      wraddress   : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_a : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_b : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren        : IN  STD_LOGIC := '1';
      clock       : IN  STD_LOGIC;
      qa          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      qb          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
  end component;
   
          
   ---------------------------------------------------------------------------------
   -- First stage feedback multiplier component, generated by ALTERA megafunction
   ---------------------------------------------------------------------------------
   
   component fsfb_calc_multiplier is
      port (
         dataa                   : in          std_logic_vector(31 downto 0);
         datab                   : in          std_logic_vector(31 downto 0);
         result                  : out         std_logic_vector(63 downto 0)
      );
   end component fsfb_calc_multiplier;
   
   
   -----------------------------------------------------------------------------------
   -- First stage feedback adder (65-bit) component, generated by ALTERA megafunction
   -----------------------------------------------------------------------------------
   
   component fsfb_calc_adder65 is
      port (
         dataa                       : in          std_logic_vector(64 downto 0);
         datab                       : in          std_logic_vector(64 downto 0);
         result                      : out         std_logic_vector(64 DOWNTO 0)
      );
   end component fsfb_calc_adder65;

   
   -----------------------------------------------------------------------------------
   -- First stage feedback adder (66-bit) component, generated by ALTERA megafunction
   -----------------------------------------------------------------------------------
   
   component fsfb_calc_adder66 is
      port (  
         dataa                       : in          std_logic_vector(65 downto 0);
         datab                       : in          std_logic_vector(65 downto 0);
         result                      : out         std_logic_vector(65 DOWNTO 0)
      );
   end component fsfb_calc_adder66;   
   
   -----------------------------------------------------------------------------------
   -- First stage feedback adder/subtractor (32-bit) component, generated by ALTERA megafunction
   -----------------------------------------------------------------------------------
   
   component fsfb_calc_add_sub32 is
      port (
         add_sub                     : in          std_logic;
         dataa                       : in          std_logic_vector(31 DOWNTO 0);
         datab                       : in          std_logic_vector(31 DOWNTO 0);
         result                      : out         std_logic_vector(31 DOWNTO 0)
      );
   end component fsfb_calc_add_sub32;
   
   -----------------------------------------------------------------------------------
   -- Filter adder/subtractor (30-bit) component, 
   -- generated by ALTERA megafunction
   ----------------------------------------------------------------------------------- 
   component fsfb_calc_adder30
      PORT
      (
         dataa    : IN STD_LOGIC_VECTOR (29 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (29 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (29 DOWNTO 0)
      );
   end component fsfb_calc_adder30;

   -----------------------------------------------------------------------------------
   -- Filter adder/subtractor (45-bit) component, 
   -- generated by ALTERA megafunction
   ----------------------------------------------------------------------------------- 

   component fsfb_calc_sub45
      PORT
      (
         dataa    : IN STD_LOGIC_VECTOR (44 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (44 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (44 DOWNTO 0)
      );
   end component fsfb_calc_sub45;

   -----------------------------------------------------------------------------------
   -- Filter adder/subtractor (29-bit) component, 
   -- generated by ALTERA megafunction
   ----------------------------------------------------------------------------------- 
   
   component fsfb_calc_sub29
      PORT
      (
         dataa    : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (28 DOWNTO 0)
      );
   end component fsfb_calc_sub29;

   -----------------------------------------------------------------------------------
   -- Filter adder/subtractor (29-bit) component, 
   -- generated by ALTERA megafunction
   ----------------------------------------------------------------------------------- 
   
   component fsfb_calc_adder29
      PORT
      (
         dataa    : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (28 DOWNTO 0)
      );
   end component fsfb_calc_adder29;
   -----------------------------------------------------------------------------------
   -- Filter adder/subtractor (31-bit) component, 
   -- generated by ALTERA megafunction
   ----------------------------------------------------------------------------------- 
   component fsfb_calc_adder31
      PORT
      (
         dataa    : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (30 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (30 DOWNTO 0)
      );
   end component fsfb_calc_adder31;

   -----------------------------------------------------------------------------------
   -- Filter adder/subtractor (32-bit) component, 
   -- generated by ALTERA megafunction
   ----------------------------------------------------------------------------------- 
   component fsfb_calc_adder32
      PORT
      (
         dataa    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
   end component fsfb_calc_adder32;


   ---------------------------------------------------------------------------------
   -- First stage feedback Filter results storage component, generated by ALTERA megafunction
   ---------------------------------------------------------------------------------

   component fsfb_filter_storage
      PORT
      (
    data    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    wren    : IN STD_LOGIC  := '1';
    wraddress     : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
    rdaddress     : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
    clock      : IN STD_LOGIC ;
    q    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
   end component fsfb_filter_storage;

   ---------------------------------------------------------------------------------
   -- Filter stage wn registers for intermediate FIR values
   ---------------------------------------------------------------------------------
   component fsfb_fltr_regs is
      port (       
         rst_i                     : in     std_logic; 
         clk_50_i                  : in     std_logic; 
         fltr_rst_i                : in     std_logic;
         addr_i                    : in     std_logic_vector(FLTR_QUEUE_ADDR_WIDTH-1 downto 0);
         wn12_o                    : out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn11_o                    : out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn10_i                    : in     std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn22_o                    : out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn21_o                    : out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wn20_i                    : in     std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
         wren_i                    : in     std_logic
      );
   end component fsfb_fltr_regs;

   ---------------------------------------------------------------------------------
   -- Filter stage wn registers for intermediate FIR values
   ---------------------------------------------------------------------------------
   component fsfb_wn_queue
      PORT
      (
    data    : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
    wren    : IN STD_LOGIC  := '1';
    address    : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
    clock      : IN STD_LOGIC ;
    q    : OUT STD_LOGIC_VECTOR (28 DOWNTO 0)
      );
   end component fsfb_wn_queue;

end fsfb_calc_pack;
