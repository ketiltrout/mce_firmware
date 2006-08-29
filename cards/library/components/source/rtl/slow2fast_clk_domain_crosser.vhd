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
-- slow2fast_clk_domain_crosser.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- slow-to-fast clock domain crossing firmware
--
-- This block converts a one-bit data signal from slow clock domain to
-- fast clock domain.  The NUM_TIMES_FASTER generic is set to the integer
-- value greater than or equal to fast clock frequency divided by slow clock
-- frequency. A synchronizer may have to be added to the input that samples 
-- in the slow clock domain in order to deal with phase difference of the 
-- domains...
--
--
--
-- Revision history:
-- 
-- <date $Date: 2005/07/12 20:32:08 $>    - <initials $Author: mandana $>
-- $Log: slow2fast_clk_domain_crosser.vhd,v $
-- Revision 1.1  2005/07/12 20:32:08  mandana
-- Initial Release
--
--

library ieee;
use ieee.std_logic_1164.all;


entity slow2fast_clk_domain_crosser is
   generic (
      NUM_TIMES_FASTER : integer := 2                                               -- divided ratio of fast clock to slow clock
      );

   port ( 
   
      -- global signals
      rst_i                     : in      std_logic;                                -- global reset
      clk_slow                  : in      std_logic;                                -- global slow clock
      clk_fast                  : in      std_logic;                                -- global fast clock
      -- input/output 
      input_slow                : in      std_logic;                                -- slow input
      output_fast               : out     std_logic                                 -- fast output 
   
      );
end slow2fast_clk_domain_crosser;

architecture rtl of slow2fast_clk_domain_crosser is

   -- internal signal declarations
   signal input_meta:    std_logic;
   signal input_temp:    std_logic;
   
   -- FSM variables
   type state is (IDLE, ONESHOT, QUIET);                           

   signal current_state: state;
   signal next_state:    state;
   
begin

   sample_fast: process(clk_fast,rst_i)
   begin
      if (rst_i = '1') then
         input_meta <= '0';
         input_temp <= '0';
      elsif(clk_fast'event and clk_fast = '1') then   
         input_temp <= input_slow;
         input_meta <= input_temp;
      end if;
   end process sample_fast;   
   
   output_fast <= input_slow and not (input_meta);
   
end rtl;
     