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
-- tb_raw_dat_manager_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- In this testbench file for the raw_dat_manager_ctrl block, we do the
-- fllowings: 
-- 1. Initialize & free run restart_frame_aligned_i at a nominal frequency
-- 2. Assert raw_req_i
-- 3. Dissasert raw_req_i after seeing assertion of raw_ack_o
-- 4. continue free run for a while and loop again
-- 
--
-- Revision history:
-- 
-- $Log: tb_raw_dat_manager_ctrl.vhd,v $
-- Revision 1.2  2004/10/29 02:03:56  mohsen
-- Sorted out library use and use parameters
--
-- Revision 1.1  2004/10/22 00:16:16  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity tb_raw_dat_manager_ctrl is

  generic (
    NUM_RAW_FRM_TO_GRAB : integer := 2);
  
end tb_raw_dat_manager_ctrl;


architecture beh of tb_raw_dat_manager_ctrl is


  component raw_dat_manager_ctrl
    generic (
      NUM_RAW_FRM_TO_GRAB : integer);
    port (
      rst_i                   : in  std_logic;
      clk_i                   : in  std_logic;
      restart_frame_aligned_i : in  std_logic;
      raw_req_i               : in  std_logic;
      clr_raw_addr_index_o    : out std_logic;
      raw_wren_o              : out std_logic;
      raw_ack_o               : out std_logic);    
  end component;


  signal rst_i                   : std_logic;
  signal clk_i                   : std_logic;
  signal restart_frame_aligned_i : std_logic;
  signal raw_req_i               : std_logic;
  signal clr_raw_addr_index_o    : std_logic;
  signal raw_wren_o              : std_logic;
  signal raw_ack_o               : std_logic;

  constant PERIOD                : time := 20 ns;
  constant EDGE_DEPENDENCY       : time := 2 ns;  -- shows clk edge dependency
  constant RESET_WINDOW          : time := 8* PERIOD;
  
  
begin  -- beh

  -----------------------------------------------------------------------------
  -- Instantiate the Device Under Test (DUT)
  -----------------------------------------------------------------------------

  DUT : raw_dat_manager_ctrl

    generic map (
    NUM_RAW_FRM_TO_GRAB => NUM_RAW_FRM_TO_GRAB)

    
    port map (
      rst_i                   => rst_i,
      clk_i                   => clk_i,
      restart_frame_aligned_i => restart_frame_aligned_i,
      raw_req_i               => raw_req_i,
      clr_raw_addr_index_o    => clr_raw_addr_index_o,
      raw_wren_o              => raw_wren_o,
      raw_ack_o               => raw_ack_o);


  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking: process
  begin  -- process clocking
    clk_i <= '1';
    wait for PERIOD/2;
    clk_i <= '0';
    wait for PERIOD/2;
  end process clocking;


  -----------------------------------------------------------------------------
  -- Generate restart_frame_aligned_i sinals with some nominal frequency
  -----------------------------------------------------------------------------

  i_gen_frame_sig: process
  begin  -- process i_gen_frame_sig
    restart_frame_aligned_i <= '0';
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for 19*PERIOD;                 -- free run

    loop 
      restart_frame_aligned_i <= '1';
      wait for PERIOD;
      restart_frame_aligned_i <= '0';
      wait for (64*41*PERIOD)-PERIOD;   -- wait for one row time * 41 rows
    end loop;


  end process i_gen_frame_sig;
  

  
  -----------------------------------------------------------------------------
  -- Perform Test
  -----------------------------------------------------------------------------

  
  i_test: process

    
    procedure do_initialize is
    begin
      rst_i                   <= '1';
      raw_req_i               <= '0';
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk
    end do_initialize;


    procedure do_simple_test is
      variable i : integer;
    begin
      raw_req_i <='0';
      wait for RESET_WINDOW;
      for i in 0 to 2 loop
        wait for 300*(i+1)*PERIOD + EDGE_DEPENDENCY;
        raw_req_i <='1';
        wait until falling_edge(restart_frame_aligned_i);
        wait for 2*64*41*PERIOD;        -- wait at lease for two frames
        wait for 10* PERIOD + EDGE_DEPENDENCY;  -- free run befre respond to
                                                -- raw_ack_o
        raw_req_i <='0';
        wait for PERIOD - EDGE_DEPENDENCY;   -- back to clk edge
      end loop;  -- i
    end do_simple_test;
    
    
  begin  -- process i_test
    do_initialize;
    do_simple_test;

    assert false report "End of Test" severity FAILURE;
    
  end process i_test;

  
end beh;
