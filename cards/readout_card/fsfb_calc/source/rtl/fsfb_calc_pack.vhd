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
-- Project:	  SCUBA-2
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
   
   constant MOST_SIG_LOCK_POS      : integer := 30;                   -- most significant bit position of lock mode data output
   
     
   ---------------------------------------------------------------------------------
   -- First stage feedback input output controller component
   ---------------------------------------------------------------------------------
      
   component fsfb_io_controller is
      generic (
         start_val                   : integer := 0                                        
         );

      port (
         rst_i                       : in           std_logic;
         clk_50_i                    : in           std_logic;
         restart_frame_aligned_i     : in           std_logic;
         restart_frame_1row_post_i   : in           std_logic;
         row_switch_i                : in           std_logic;
         initialize_window_i         : in           std_logic;
         num_ramp_frame_cycles_i     : in           std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
         fsfb_proc_update_i          : in           std_logic;
	 fsfb_proc_dat_i             : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
         fsfb_ws_addr_i              : in           std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
         fsfb_ws_dat_o               : out          std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         fsfb_fltr_dat_rdy_o         : out          std_logic;
         fsfb_fltr_dat_o             : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
         fsfb_ctrl_dat_rdy_o         : out          std_logic;
         fsfb_ctrl_dat_o             : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
         p_addr_o                    : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         i_addr_o                    : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         d_addr_o                    : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         z_addr_o                    : out          std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
         ramp_update_new_o           : out          std_logic;
         initialize_window_ext_o     : out          std_logic;
         previous_fsfb_dat_rdy_o     : out          std_logic;
         previous_fsfb_dat_o         : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
         fsfb_queue_wr_data_o        : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    
	 fsfb_queue_wr_addr_o        : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  
	 fsfb_queue_rd_addra_o       : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  
	 fsfb_queue_rd_addrb_o       : out          std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  
	 fsfb_queue_wr_en_bank0_o    : out          std_logic;                                           
	 fsfb_queue_wr_en_bank1_o    : out          std_logic;                                           
	 fsfb_queue_rd_dataa_bank0_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    
	 fsfb_queue_rd_dataa_bank1_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);     
	 fsfb_queue_rd_datab_bank0_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    
	 fsfb_queue_rd_datab_bank1_i : in           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0)
      );
   end component fsfb_io_controller;
      
      
   ---------------------------------------------------------------------------------
   -- First stage feedback processor component
   ---------------------------------------------------------------------------------   
      
   component fsfb_processor is
      generic (
         lock_dat_left               : integer := 30
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
	 z_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         fsfb_proc_update_o          : out          std_logic;
         fsfb_proc_dat_o             : out          std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
         fsfb_proc_lock_en_o         : out          std_logic
      );  
   end component fsfb_processor;
   
   
   ---------------------------------------------------------------------------------
   -- First stage feedback processor subcomponent (lock mode)
   ---------------------------------------------------------------------------------
   
   component fsfb_proc_pidz is
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
         z_dat_i                     : in           std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  
         fsfb_proc_pidz_update_o     : out          std_logic;                                            
         fsfb_proc_pidz_sum_o        : out          std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0) 
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
         fsfb_proc_ramp_dat_o        : out           std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0)
      );
   end component fsfb_proc_ramp;
   
   
   ---------------------------------------------------------------------------------
   -- First stage feedback data queue component, generated by ALTERA megafunction
   ---------------------------------------------------------------------------------
   
   component fsfb_queue is
      port (
   	 data                        : in            std_logic_vector(32 DOWNTO 0);
         wraddress                   : in            std_logic_vector(5 DOWNTO 0);
         rdaddress_a                 : in            std_logic_vector(5 DOWNTO 0);
         rdaddress_b                 : in            std_logic_vector(5 DOWNTO 0);
         wren                        : in            std_logic;
         clock                       : in            std_logic;
         qa                          : out           std_logic_vector(32 DOWNTO 0);
         qb                          : out           std_logic_vector(32 DOWNTO 0)
      );
   end component fsfb_queue;
    
   
   ---------------------------------------------------------------------------------
   -- First stage feedback multiplier component, generated by ALTERA megafunction
   ---------------------------------------------------------------------------------
   
   component fsfb_calc_multiplier is
      port (
   	 dataa		             : in          std_logic_vector(31 downto 0);
   	 datab	  	             : in          std_logic_vector(31 downto 0);
   	 result		             : out         std_logic_vector(63 downto 0)
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
   -- First stage feedback adder/subtractor (16-bit) component, 
   -- generated by ALTERA megafunction
   ----------------------------------------------------------------------------------- 
   
   component fsfb_calc_add_sub16 is
      port (
   	 add_sub                     : in          std_logic;
   	 dataa                       : in          std_logic_vector(15 DOWNTO 0);
   	 datab                       : in          std_logic_vector(15 DOWNTO 0);
         result		             : out         std_logic_vector(15 DOWNTO 0)
      );
   end component fsfb_calc_add_sub16;
   
   
end fsfb_calc_pack;
