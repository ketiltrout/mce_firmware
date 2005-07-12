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
-- fast2slow_clk_domain_crosser.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Fast-to-slow clock domain crossing firmware
--
-- This block converts a one-bit data signal from fast clock domain to
-- slow clock domain.  The NUM_TIMES_FASTER generic is set to the integer
-- value greater than or equal to fast clock frequency divided by slow clock
-- frequency.
--
--
--
-- Revision history:
-- 
-- <date $Date$>    - <initials $Author$>
-- $Log$
--

library ieee;
use ieee.std_logic_1164.all;


entity fast2slow_clk_domain_crosser is
   generic (
      NUM_TIMES_FASTER : integer := 2                                               -- divided ratio of fast clock to slow clock
      );

   port ( 
   
      -- global signals
      rst_i                     : in      std_logic;                                -- global reset
      clk_slow                  : in      std_logic;                                -- global slow clock
      clk_fast                  : in      std_logic;                                -- global fast clock
      -- input/output 
      input_fast                : in      std_logic;                                -- fast input
      output_slow               : out     std_logic                                 -- slow output 
   
      );
end fast2slow_clk_domain_crosser;

architecture rtl of fast2slow_clk_domain_crosser is

   -- internal signal declarations
  
   signal shift_reg             : std_logic_vector(NUM_TIMES_FASTER-1 downto 0);    -- shift register for sampling the fast input
   signal ext_pulse             : std_logic;                                        -- extended version of the fast input for 
                                                                                    -- slow clock sampling
   signal output_slow_meta      : std_logic;                                        -- internal sampler signal to avoid metastability
  
   
begin

   -- Sample the fast input through the shift register in the fast clock domain
   -- This will ensure the pulse is not missed and help avoid metastability.
   
   sample_shifter_fast : process (rst_i, clk_fast)
   begin
      if (rst_i = '1') then
         shift_reg <= (others => '0');
      elsif (clk_fast'event and clk_fast = '1') then
         shift_reg(0) <= input_fast;
         shift_reg(NUM_TIMES_FASTER-1 downto 1) <= shift_reg(NUM_TIMES_FASTER-2 downto 0);
      end if;
   end process sample_shifter_fast;
   
      
   -- Extend the fast input pulse to at least the width of the slow clock period
   -- This will ensure the pulse is not missed when resampling with the slow clock.
   
   sample_extender : process (rst_i, clk_fast)
   begin
      if (rst_i = '1') then
        ext_pulse <= '0';
      elsif (clk_fast'event and clk_fast = '1') then
        if input_fast = '1' then
           ext_pulse <= '1';
        elsif shift_reg(shift_reg'left) = '1' then
           ext_pulse <= '0';
        end if;
      end if;
   end process sample_extender;
           
      
   -- Resample the input pulse (extended version) in the slow clock domain.
   -- Output is now converted to the slow clock domain
   -- Avoid metastability issue by having an extra meta FF
   
   sampler_meta : process (rst_i, clk_slow)
   begin
      if (rst_i = '1') then
         output_slow_meta <= '0';
      elsif (clk_slow'event and clk_slow = '1') then
         if ext_pulse = '1' then
            output_slow_meta <= '1';
         else
            output_slow_meta <= '0';
         end if;
      end if;
   end process sampler_meta;
 
   
   sampler_slow : process (rst_i, clk_slow)
   begin
      if (rst_i = '1') then
         output_slow <= '0';
      elsif (clk_slow'event and clk_slow = '1') then
         output_slow <= output_slow_meta;
      end if;
   end process sampler_slow;
   
   
end rtl;
     