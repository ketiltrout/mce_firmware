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
-- $Id: frame_timing.vhd,v 1.3 2004/11/18 05:21:56 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This implements the frame synchronization block for the AC, BC, RC.
--
-- Revision history:
-- $Log: frame_timing.vhd,v $
-- Revision 1.3  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.2  2004/11/17 01:57:32  bburger
-- Bryce :  updating the interface signal order
--
-- Revision 1.1  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.frame_timing_pack.all;
use work.frame_timing_wbs_pack.all;
use work.frame_timing_core_pack.all;

library components;
use components.component_pack.all;

entity frame_timing is
   port(
      -- Readout Card interface
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic; 
      restart_frame_1row_post_o  : out std_logic;
      initialize_window_o        : out std_logic;
      
      -- Address Card interface
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
         
      -- Bias Card interface
      update_bias_o              : out std_logic;
      
      -- Wishbone interface
      dat_i                      : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                     : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                      : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                       : in std_logic;
      stb_i                      : in std_logic;
      cyc_i                      : in std_logic;
      dat_o                      : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                      : out std_logic;      
      
      -- Global signals
      clk_i                      : in std_logic;
      mem_clk_i                  : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
end frame_timing;

architecture beh of frame_timing is
   
   signal clk_error             : std_logic_vector(31 downto 0);
   signal counter_rst           : std_logic;
   signal count                 : std_logic_vector(31 downto 0);
   signal frame_count_int       : integer;
   signal row_count_int         : integer;
   signal wait_for_sync         : std_logic;
   signal latch_error           : std_logic;
   signal restart_frame_aligned : std_logic;
   signal frame_rst             : std_logic;
   
   signal row_len               : integer; -- not used yet
   signal num_rows              : integer; -- not used yet
   signal sample_delay          : integer;
   signal sample_num            : integer;
   signal feedback_delay        : integer;
   signal address_on_delay      : integer;
   signal resync_req            : std_logic;
   signal resync_ack            : std_logic; -- not used yet
   signal init_window_req       : std_logic;
   signal init_window_ack       : std_logic; -- not used yet

begin
   
   wbi: frame_timing_wbs       
      port map(
         row_len_o          => row_len,         
         num_rows_o         => num_rows,        
         sample_delay_o     => sample_delay,    
         sample_num_o       => sample_num,      
         feedback_delay_o   => feedback_delay,  
         address_on_delay_o => address_on_delay,
         resync_ack_i       => resync_req,      
         resync_req_o       => resync_ack,      
         init_window_ack_i  => init_window_req, 
         init_window_req_o  => init_window_ack, 
                            
         dat_i              => dat_i, 
         addr_i             => addr_i,
         tga_i              => tga_i, 
         we_i               => we_i,  
         stb_i              => stb_i, 
         cyc_i              => cyc_i, 
         dat_o              => dat_o, 
         ack_o              => ack_o, 
                            
         clk_i              => clk_i,
         mem_clk_i          => mem_clk_i,
         rst_i              => rst_i
      );                    
   
   ftc: frame_timing_core
      port map(
         -- Readout Card interface    
         dac_dat_en_o              => dac_dat_en_o,             
         adc_coadd_en_o            => adc_coadd_en_o,           
         restart_frame_1row_prev_o => restart_frame_1row_prev_o,
         restart_frame_aligned_o   => restart_frame_aligned_o,  
         restart_frame_1row_post_o => restart_frame_1row_post_o,
         initialize_window_o       => initialize_window_o,      
                                  
         -- Address Card interface    
         row_switch_o              => row_switch_o,             
         row_en_o                  => row_en_o,                 
                                         
         -- Bias Card interface       
         update_bias_o             => update_bias_o,           
                                  
         -- Wishbone interface    
         row_len_i                 => row_len,         
         num_rows_i                => num_rows,        
         sample_delay_i            => sample_delay,    
         sample_num_i              => sample_num,      
         feedback_delay_i          => feedback_delay,  
         address_on_delay_i        => address_on_delay,
         resync_req_i              => resync_req,      
         resync_ack_o              => resync_ack,      
         init_window_req_i         => init_window_req, 
         init_window_ack_o         => init_window_ack, 
                                 
         -- Global signals       
         clk_i                     => clk_i,
         mem_clk_i                 => mem_clk_i,
         rst_i                     => rst_i,
         sync_i                    => sync_i
                                   
      );                           
                                   
                                   
end beh;                           
                                   
                                   
                                   
                                   