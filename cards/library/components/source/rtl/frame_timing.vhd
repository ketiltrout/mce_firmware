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
-- <revision control keyword substitutions e.g. $Id: frame_timing.vhd,v 1.2 2004/04/03 01:05:37 bburger Exp $>
--
-- Project:		 SCUBA-2
-- Author:		 Bryce Burger
-- Organisation:	UBC
--
-- Description:
-- This implements the frame synchronization block for the AC, BC, RC.
--
-- Revision history:
-- <date $Date: 2004/04/03 01:05:37 $> - <text> - <initials $Author: bburger $>
-- $Log: frame_timing.vhd,v $
-- Revision 1.2  2004/04/03 01:05:37  bburger
-- Added a rst_on_next_sync_pulse register so that the master block doesn't have to assert that signal during the receipt of a sync, but anytime before
--
-- Revision 1.1  2004/04/02 01:13:13  bburger
-- New
--
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

  signal rst_on_next_sync_reg : std_logic;
  signal cycle_error : std_logic_vector(31 downto 0);
  
  signal counter_rst : std_logic;
  signal counter_o : std_logic_vector(31 downto 0);
  signal counter_o_int : integer;
  signal reg_rst : std_logic;
  
begin

   cntr : counter 
      generic map(MAX => END_OF_FRAME)
      port map(
         clk_i => clk_i,
         rst_i => counter_rst,   
         ena_i => '1',
         load_i => '0',
         down_i => '0',
         count_i => 0,
         count_o => counter_o_int
      );
      
   rgstr : reg
      generic map(WIDTH => 32)
      port map(
         clk_i => clk_i,
         rst_i => reg_rst,
         ena_i => sync_i,
         reg_i  => counter_o,
         reg_o => cycle_error
      );
   
   counter_o <= conv_std_logic_vector(counter_o_int, 32);
         
   -- Inputs/Outputs 
   cycle_count_o <= counter_o;
   cycle_error_o <= cycle_error;   

   rons : process (rst_on_next_sync_i, sync_i)
   begin
      if (rst_on_next_sync_i 'event and rst_on_next_sync_i = '1') then
         rst_on_next_sync_reg <= '1';
      end if;

      if (sync_i'event and sync_i = '1' and rst_on_next_sync_reg = '1') then
         counter_rst <= '1';
         rst_on_next_sync_reg <= '0';
      elsif (counter_o_int = END_OF_FRAME) then
         counter_rst <= '1';
      else
         counter_rst <= '0';         
      end if;
   end process;

   -- Counter Wrap-around
   counter_rst <= '1' when (counter_o_int = END_OF_FRAME) else '0';

end beh;