-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- frame_timing.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		 SCUBA-2
-- Author:		 Bryce Burger
-- Organisation:	UBC
--
-- Description:
-- This implements the frame synchronization block for the AC, BC, RC.
--
-- Revision history:
-- <date $Date$> - <text> - <initials $Author$>
-- $Log$
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.frame_timing_pack.all;

library components;
use components.component_pack.all;

entity frame_timing is
   port(
      clk_i              : in std_logic;
      sync_i             : in std_logic;
      rst_on_next_sync_i : in std_logic;
      cycle_count_o      : out std_logic_vector(31 downto 0);
      cycle_error_o      : out std_logic_vector(31 downto 0)
   );
end frame_timing;

architecture beh of frame_timing is

  signal clk : std_logic;
  signal sync : std_logic;
  signal rst_on_next_sync : std_logic;
  signal cycle_count : std_logic_vector(31 downto 0);
  signal cycle_error : std_logic_vector(31 downto 0);
  
  signal counter_rst : std_logic;
  signal counter_ena : std_logic;
  signal counter_load : std_logic;
  signal counter_down : std_logic;
  signal counter_ci : integer;
  signal counter_co : std_logic_vector(31 downto 0);
  signal counter_co_int : integer;
  signal reg_rst : std_logic;
  
begin

   cntr : counter 
      generic map(MAX => END_OF_FRAME)
      port map(
         clk_i => clk,
         rst_i => counter_rst,   
         ena_i => counter_ena,   
         load_i => counter_load,  
         down_i => counter_down,  
         count_i => counter_ci, 
         count_o => counter_co_int
      );
      
   rgstr : reg
      generic map(WIDTH => 32)
      port map(
         clk_i => clk,
         rst_i => reg_rst,
         ena_i => sync,
         reg_i  => counter_co,
         reg_o => cycle_error
      );
   
   counter_co <= conv_std_logic_vector(counter_co_int, 32);
     
   -- Initialize port-mapped control signals  
   counter_ena <= '1';
   counter_load <= '0';
   counter_down <= '0';
   counter_ci <= 0;   
   reg_rst <= '0';
      
   -- Inputs/Outputs   
   clk <= clk_i;
   sync <= sync_i;
   rst_on_next_sync <= rst_on_next_sync_i;
   cycle_count_o <= counter_co;
   cycle_error_o <= cycle_error;   

   -- Logic
   counter_rst <= '1' when (sync = '1' and rst_on_next_sync = '1') or (counter_co_int = END_OF_FRAME) 
      else '0';

end beh;