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
-- tb_raw_dat_manager_data_path.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- In this testbench file for the raw_dat_manager_data_path block, we do the
-- fllowings: 
-- 1. Initialize
-- 2. Free run
-- 3. Assert clear signal, then free run
-- 4. Disassert clear signal, then free run
--
-- Revision history:
-- 
-- $Log$
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity tb_raw_dat_manager_data_path is

  generic (
    ADDR_WIDTH : integer := 5;          -- set these values to test variations
    MAX_COUNT  : integer := 31);        -- Normally =(2^ADDR_WIDTH)-1
  
end tb_raw_dat_manager_data_path;



architecture beh of tb_raw_dat_manager_data_path is


  component raw_dat_manager_data_path

    generic (
      ADDR_WIDTH : integer;               
      MAX_COUNT  : integer);              -- Normally = (2^ADDR_WIDTH)-1
  
    port (
      rst_i        : in  std_logic;
      clk_i        : in  std_logic;
      clr_index_i  : in  std_logic;
      addr_index_o : out std_logic_vector (ADDR_WIDTH-1 downto 0));
    
  end component;


  signal rst_i                   : std_logic;
  signal clk_i                   : std_logic;
  signal clr_index_i             : std_logic;
  signal addr_index_o            : std_logic_vector (ADDR_WIDTH-1 downto 0);
   
  constant PERIOD                : time := 20 ns;
  constant EDGE_DEPENDENCY       : time := 2 ns;  -- shows clk edge dependency
  constant RESET_WINDOW          : time := 8* PERIOD;

  
begin  -- beh

  -----------------------------------------------------------------------------
  -- Instantiate the Device Under Test
  -----------------------------------------------------------------------------

  DUT : raw_dat_manager_data_path

    generic map (
    ADDR_WIDTH => ADDR_WIDTH,
    MAX_COUNT  => MAX_COUNT)

    port map (
      rst_i        => rst_i,
      clk_i        => clk_i,
      clr_index_i  => clr_index_i,
      addr_index_o => addr_index_o);


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
  -- Perform Test
  -----------------------------------------------------------------------------

  i_test: process

    procedure do_initialize is
    begin
      rst_i <= '1';
      clr_index_i <= '0';

      wait for 113 ns;

      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk
      
    end do_initialize;
  

    procedure do_simple_test is
    begin
      wait for MAX_COUNT*2*PERIOD;      -- go through full count twice
      wait for 5*PERIOD;                -- do a few count and check clr action
      wait for EDGE_DEPENDENCY; 
      clr_index_i <= '1';
      wait for 15*PERIOD;
      clr_index_i <= '0';
    
      wait for MAX_COUNT*3*PERIOD;
    end do_simple_test;
 

  begin  -- process i_test

    do_initialize;
    do_simple_test;
    do_initialize;
    do_simple_test;
    
    assert false report "End of Test" severity FAILURE;

  end process i_test;
  
end beh;
