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
-- $Id: frame_timing.vhd,v 1.13 2013/05/16 22:43:57 mandana Exp $
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
-- Revision 1.13  2013/05/16 22:43:57  mandana
-- servo_rst_arm parameter is added to generate a servo_rst_window for the rest of the system
--
-- Revision 1.12  2012-09-07 19:49:28  mandana
-- moved components declaration to pack file
--
-- Revision 1.11  2009/09/14 20:02:41  bburger
-- BB: added the row_count_o interface for the Address Card row-specific BIAS_START command
--
-- Revision 1.10  2009/01/16 01:32:38  bburger
-- BB:  Added row_len, num_rows, num_rows_reported, and num_cols_reported outputs for the column data feature.
--
-- Revision 1.9  2006/03/17 23:17:10  mandana
-- sync_gen_pack removed, constants are added to frame_timing_pack instead
--
-- Revision 1.8  2006/03/08 22:57:22  bburger
-- Bryce:
-- - removed component delclarations from frame_timing pack files
-- - added sync_num_o interfaces to frame_timing and frame_timing_core
-- - added a counter to frame_timing_core for outputting the sync_num_o
--
-- Revision 1.7  2006/02/09 20:32:59  bburger
-- Bryce:
-- - Added a fltr_rst_o output signal from the frame_timing block
-- - Adjusted the top-levels of each card to reflect the frame_timing interface change
--
-- Revision 1.6  2005/05/06 20:02:31  bburger
-- Bryce:  Added a 50MHz clock that is 180 degrees out of phase with clk_i.
-- This clk_n_i signal is used for sampling the sync_i line during the middle of the pulse, to avoid problems associated with sampling on the edges.
--
-- Revision 1.5  2004/12/14 20:17:38  bburger
-- Bryce:  Repaired some problems with frame_timing and added a list of frame_timing-initialization commands to clk_card
--
-- Revision 1.4  2004/11/19 20:00:05  bburger
-- Bryce :  updated frame_timing and sync_gen interfaces
--
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
      servo_rst_window_o         : out std_logic;
      fltr_rst_o                 : out std_logic;
      sync_num_o                 : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      row_len_o                  : out integer;
      num_rows_o                 : out integer;
      num_rows_reported_o        : out integer;
      num_cols_reported_o        : out integer;
      
      -- Address Card interface
      row_count_o                : out std_logic_vector(ROW_COUNT_WIDTH-1 downto 0);
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
         
      -- Bias Card interface
      update_bias_o              : out std_logic;
      flux_fb_dly_o              : out std_logic;
      
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
      clk_n_i                    : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
end frame_timing;

architecture beh of frame_timing is
   
   signal row_len               : integer; -- not used yet
   signal num_rows              : integer; -- not used yet
   signal flux_fb_dly_temp      : integer;
   signal sample_delay          : integer;
   signal sample_num            : integer;
   signal feedback_delay        : integer;
   signal address_on_delay      : integer;
   signal resync_req            : std_logic;
   signal resync_ack            : std_logic; -- not used yet
   signal init_window_req       : std_logic;
   signal init_window_ack       : std_logic; -- not used yet
   signal fltr_rst_ack          : std_logic; 
   signal fltr_rst_req          : std_logic; 
   signal servo_rst_req         : std_logic;
   signal servo_rst_ack         : std_logic; -- not used yet

begin
   
   num_rows_o <= num_rows;
   row_len_o <= row_len;
   
   wbi: frame_timing_wbs       
      port map(
         row_len_o          => row_len,         
         num_rows_o         => num_rows,   
         num_rows_reported_o => num_rows_reported_o,
         num_cols_reported_o => num_cols_reported_o,
         sample_delay_o     => sample_delay,    
         sample_num_o       => sample_num,      
         feedback_delay_o   => feedback_delay,  
         address_on_delay_o => address_on_delay,
         flux_fb_dly_o      => flux_fb_dly_temp,
         resync_ack_i       => resync_ack,      
         resync_req_o       => resync_req,      
         init_window_ack_i  => init_window_ack, 
         init_window_req_o  => init_window_req, 
         fltr_rst_ack_i     => fltr_rst_ack, 
         fltr_rst_req_o     => fltr_rst_req, 
         servo_rst_ack_i    => servo_rst_ack, 
         servo_rst_req_o    => servo_rst_req, 
                            
         dat_i              => dat_i, 
         addr_i             => addr_i,
         tga_i              => tga_i, 
         we_i               => we_i,  
         stb_i              => stb_i, 
         cyc_i              => cyc_i, 
         dat_o              => dat_o, 
         ack_o              => ack_o, 
                            
         clk_i              => clk_i,
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
         servo_rst_window_o        => servo_rst_window_o,
         fltr_rst_o                => fltr_rst_o,
         sync_num_o                => sync_num_o,
                                  
         -- Address Card interface    
         row_count_o               => row_count_o,
         row_switch_o              => row_switch_o,             
         row_en_o                  => row_en_o,                 
                                         
         -- Bias Card interface       
         update_bias_o             => update_bias_o,           
         flux_fb_dly_o             => flux_fb_dly_o,
                                  
         -- Wishbone interface    
         row_len_i                 => row_len,         
         num_rows_i                => num_rows,        
         sample_delay_i            => sample_delay,    
         sample_num_i              => sample_num,      
         feedback_delay_i          => feedback_delay,  
         address_on_delay_i        => address_on_delay,
         flux_fb_dly_i             => flux_fb_dly_temp,
         resync_req_i              => resync_req,      
         resync_ack_o              => resync_ack,      
         init_window_req_i         => init_window_req, 
         init_window_ack_o         => init_window_ack,
         fltr_rst_ack_o            => fltr_rst_ack, 
         fltr_rst_req_i            => fltr_rst_req, 
         servo_rst_req_i           => servo_rst_req, 
         servo_rst_ack_o           => servo_rst_ack,
                                 
         -- Global signals       
         clk_i                     => clk_i,
         clk_n_i                   => clk_n_i, 
         rst_i                     => rst_i,
         sync_i                    => sync_i
                                   
      );                           
                                   
                                   
end beh;                           
                                   
                                   
                                   
                                   