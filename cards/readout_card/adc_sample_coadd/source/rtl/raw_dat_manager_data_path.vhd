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
-- raw_dat_manager_data_path.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
--
-- This block is the data paht in the Raw Data Manager unit.  Raw Data Manager
-- is a component of the adc_sample_coadd.
-- 
-- The action taken in this block are:
-- 
-- 1. Increase the write address index to the raw data bank.
--
-- Ports:
-- #rest_i: Global reset active high
-- #clk_i: Global clock signal
-- #clr_index_i: input from raw_dat_manager_ctrl block.  It is false (low) for
-- duration of the raw data collection and when data is writen into the
-- memeory bank.  It is ture (high) for idle times.
-- #addr_index_o: output to the wraddress input of raw_dat_bank memory block.
--
-- Signals:
-- #count: an integer that counts up to indicate which row of the memory bank
-- we are writing the data to.
--
-- Revision history:
-- 
-- $Log: raw_dat_manager_data_path.vhd,v $
-- Revision 1.1  2004/10/22 00:14:37  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity raw_dat_manager_data_path is

  generic (
    ADDR_WIDTH   : integer  := 13);               
  
  port (
    rst_i        : in  std_logic;
    clk_i        : in  std_logic;
    clr_index_i  : in  std_logic;
    addr_index_o : out std_logic_vector (ADDR_WIDTH-1 downto 0));

end raw_dat_manager_data_path;


architecture beh of raw_dat_manager_data_path is

  signal count : std_logic_vector(ADDR_WIDTH-1 downto 0);


begin  -- beh


  -----------------------------------------------------------------------------
  -- Address Index Counter:
  -- This block counts up the address index for write port of the raw data
  -- bank.  The counter is only active during a window that last from the
  -- beginning of a frame for two frames. 
  -----------------------------------------------------------------------------

  i_count_up: process (clk_i, rst_i)
        
  begin  -- process i_count_up
    if rst_i = '1' then                 -- asynchronous reset (active high)
      count <= (others => '0');
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if (clr_index_i = '1') then 
        count <= (others => '0');
      else
        count <= count +1;
      end if;
      
    end if;
  end process i_count_up;

  addr_index_o <= count;
  
  

end beh;
