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
-- raw_dat_manager_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- This block is the controller for raw_dat_manager_data_path.  Raw Data
-- Manager is a component of the adc_sample_coadd.
-- 
-- The operation of this block is as follows:
--
-- 1. For the enabling edges of the signals, they are based on deduction of
-- required control signals from the first occurance of restart_frame_aligned_i
-- signal, after raw_req_i is asserted.
-- 
-- 2. For the disabling edges of signals, they are based on the status of an
-- internal qualifier (frame_count) logically ANDED with
-- restart_frame_aligned_i.
--
-- Ports:
-- #rst_i: global reset active high
-- #clk_i: global clock
-- #restart_frame_aligned_i: Input to flux_loop_ctrl block from frame_timing
-- block. This signal is high for one clock cycle and its falling edge
-- corresponds to the row0 cycle time in a new data frame.
-- #raw_req_i: Input from wbs_frame_data to ask for raw data.  It is high until
-- an acknowlege is issued by this (raw_dat_manager_ctrl) block.  This block
-- will start to acquire raw data from the first restart_frame_aligned_i pulse
-- after raw_req_i goes high.
-- #clr_raw_addr_index_o: Output to raw_dat_manager_data_path. It is false
-- (low) for duration of the raw data collection and when data is writen into
-- the memeory bank.  It is ture (high) for idle times.
-- #raw_wren_o: output to wren of raw_dat_bank.  It is active high for duration
-- of writing data into the bank.
-- #raw_ack_o: output out of flux_loop_ctrl block.  This will go to
-- wbs_frame_data block to indicate the end of raw data acquisition.  It
-- remains high until it sees the falling edge of raw_req_i.
-- 
-- signals:
-- Internal represenation of output ports, as we need to read from them.
--
-- Qualifiers:
-- #frame_count: a counter to count up the number of restart_frame_aligned_i
-- pulses seen after the raw_req_i goes high.  It is cleared for duration of
-- not acquiring raw data.
--
--
-- Revision history:
-- 
-- $Log: raw_dat_manager_ctrl.vhd,v $
-- Revision 1.1  2004/10/22 00:14:37  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity raw_dat_manager_ctrl is

  generic (
    NUM_RAW_FRM_TO_GRAB : integer := 2);    -- number of raw frames to grab
  
  port (
    rst_i                   : in  std_logic;
    clk_i                   : in  std_logic;
    restart_frame_aligned_i : in  std_logic;
    raw_req_i               : in  std_logic;
    clr_raw_addr_index_o    : out std_logic;
    raw_wren_o              : out std_logic;
    raw_ack_o               : out std_logic);

end raw_dat_manager_ctrl;


architecture timing_beh of raw_dat_manager_ctrl is


  -----------------------------------------------------------------------------
  -- Internal signals
  -----------------------------------------------------------------------------

  -- the fllowing signals are internal copies of the output signals, as we need
  -- to read the output signals in order to maintain their level in the "if"
  -- conditions.
  
  signal int_clr_raw_addr_index : std_logic;  
  signal int_raw_wren           : std_logic;
  signal int_raw_ack            : std_logic;

  
  -----------------------------------------------------------------------------
  -- Internal qualifiers
  -----------------------------------------------------------------------------
  signal frame_count       : integer range 0 to NUM_RAW_FRM_TO_GRAB;  

  
begin  -- timing_beh

  
  clr_raw_addr_index_o <= int_clr_raw_addr_index;
  raw_wren_o           <= int_raw_wren;
  raw_ack_o            <= int_raw_ack;


  
  -----------------------------------------------------------------------------
  -- logic for controlling addr_index_counter block
  -----------------------------------------------------------------------------
  i_ctrl_counter: process (clk_i, rst_i)
  begin  -- process i_ctrl_counter
    if rst_i = '1' then                   -- asynchronous reset (active high)
      int_clr_raw_addr_index <= '1';

      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      
      if (raw_req_i = '1' and restart_frame_aligned_i = '1') then
        int_clr_raw_addr_index <= '0';  -- enabling edge
        if frame_count = NUM_RAW_FRM_TO_GRAB-1 then     
          int_clr_raw_addr_index <='1';  -- disabling edge
        end if;
      else
        int_clr_raw_addr_index <= int_clr_raw_addr_index;  -- maintain level
      end if;

    end if;
    
  end process i_ctrl_counter;


  
  -----------------------------------------------------------------------------
  -- logic for controlling raw_dat_bank block
  -----------------------------------------------------------------------------

  int_raw_wren <= not int_clr_raw_addr_index;


  
  -----------------------------------------------------------------------------
  -- logic for controlling outputs of the parent block (adc_sample_coadd)
  -----------------------------------------------------------------------------

  i_ctrl_blk_output: process (clk_i, rst_i)
  begin  -- process i_ctrl_blk_output
    if rst_i = '1' then                 -- asynchronous reset (active high)
      int_raw_ack <= '0';
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      if raw_req_i = '0' then
        int_raw_ack <= '0';             -- disabling edge and idle condition
      elsif (raw_req_i='1' and restart_frame_aligned_i='1' and
             frame_count=NUM_RAW_FRM_TO_GRAB-1) then
        int_raw_ack <= '1';             -- enabling edge
      else
        int_raw_ack <= int_raw_ack;     -- maintain level
      end if;
           
    end if;
  end process i_ctrl_blk_output;


  -----------------------------------------------------------------------------
  -- logic for internal qualifiers
  -----------------------------------------------------------------------------
  
  i_ctrl_int_qualifiers: process (clk_i, rst_i)
  begin  -- process i_ctrl_int_qualifiers
    if rst_i = '1' then                 -- asynchronous reset (active high)
      frame_count            <= 0;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if (int_clr_raw_addr_index = '1' or
          frame_count = NUM_RAW_FRM_TO_GRAB) then
        frame_count <= 0;
      elsif (restart_frame_aligned_i = '1') then
        frame_count <= frame_count +1;
      end if;
      
    end if;
  end process i_ctrl_int_qualifiers;

  

end timing_beh;
