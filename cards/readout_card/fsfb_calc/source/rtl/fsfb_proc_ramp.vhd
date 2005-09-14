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
-- fsfb_proc_ramp.vhd
--
-- Project:   SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- First stage feedback calculation processor ramp mode firmware
--
-- This block contains the arithmetic/comparison circuitry that calculates the results of first 
-- stage feedback (in ramp mode) written to the first stage feedback queue.
--
-- Ramp is incremented/decremented in ramp_step size_i per frame and should not exceed the 
-- ramp_amp_i or go below 0.  
--
--                                             
-- Revision history:
-- 
-- $Log: fsfb_proc_ramp.vhd,v $
-- Revision 1.2  2004/11/26 18:26:45  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/10/22 22:18:36  anthonyk
-- Initial release
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_pack.all;

entity fsfb_proc_ramp is

   port (
      -- global signals
      rst_i                   : in     std_logic;                                            -- global reset
      clk_50_i                : in     std_logic;                                            -- global clock
    
      -- adder/subtractor input from first stage feedback queue      
      previous_fsfb_dat_rdy_i : in     std_logic;                                           -- indiate previous fsfb queue value is ready
      previous_fsfb_dat_i     : in     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- previous fsfb queue value      

      -- control signals from configuration registers
      ramp_mode_en_i          : in     std_logic;                                            -- ramp mode enable 
      ramp_step_size_i        : in     std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);         -- ramp step increments/decrements
      ramp_amp_i              : in     std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);          -- ramp peak amplitude
             
      -- outputs from first stage feedback processor block
      fsfb_proc_ramp_update_o : out    std_logic;                                            -- update pulse to indicate ramp result is ready 
                                                                                             -- for the current fsfb_queue
      fsfb_proc_ramp_dat_o    : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0)      -- ramp result
  
      );

end fsfb_proc_ramp; 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_pack.all;

architecture rtl of fsfb_proc_ramp is

   -- constant declarations
   constant ZEROES             : std_logic_vector(22 downto 0) := "00000000000000000000000";
   constant ZEROES16           : std_logic_vector(15 downto 0) := x"0000";
   
   -- internal signal declarations
   signal add_sub_n            : std_logic;                                                  -- add/subtract operation select
   signal ramp_step_size16     : std_logic_vector(15 downto 0);                              -- ramp step size (extended to 16 bits)
   signal pre_fsfb_dat16       : std_logic_vector(15 downto 0);                              -- previous fsfb queue value (truncated to 16 bits)
   signal ramp_amp16           : std_logic_vector(15 downto 0);                              -- ramp amplitude (extended to 16 bits)
   signal add_sub_result       : std_logic_vector(15 downto 0);                              -- result of the adder/subtractor
   signal result_reg           : std_logic_vector(15 downto 0);                              -- registered adder/subtractor result
   signal ramp_dat             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);           -- ramp result (msb = 1 for subtraction, 0 for addition)
   
   signal pre_fsfb_dat_rdy_1d  : std_logic;                                                  -- previous fsfb queue value rdy delay by 1 clock cycle
   signal pre_fsfb_dat_rdy_2d  : std_logic;                                                  -- previous fsfb queue value rdy delay by 2 clock cycles
   signal ramp_update          : std_logic;                                                  -- update pulse to indicate ramp result is ready 
                                                                                                                            
begin
   
   -- Rename signals for internal use 
   add_sub_n        <= not (previous_fsfb_dat_i(previous_fsfb_dat_i'left));
   ramp_step_size16 <= ZEROES(1 downto 0) & ramp_step_size_i; 
   pre_fsfb_dat16   <= previous_fsfb_dat_i(15 downto 0);
   ramp_amp16       <= ZEROES(1 downto 0) & ramp_amp_i;

   
   -- Perform add/subtract once the input data is ready
   i_adder_subtractor : fsfb_calc_add_sub16
      port map (
         add_sub                 => add_sub_n,
         dataa                   => pre_fsfb_dat16,
         datab                   => ramp_step_size16, 
          result                  => add_sub_result       
      );

      
   -- Register the result for comparison
   result_reg_proc : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         result_reg <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (previous_fsfb_dat_rdy_i = '1') then
            result_reg <= add_sub_result;
         end if;
      end if;
   end process result_reg_proc;  

  
   -- Perform comparison to ensure output to DAC is in proper range 
   -- Range:  0  <= result <= ramp_amp_i
   comparator : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         ramp_dat <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         -- Add operation was performed
         -- Check upper limit <= ramp_amp_i
         if (add_sub_n = '1') then
            if (result_reg >= ramp_amp16) then
               ramp_dat(FSFB_QUEUE_DATA_WIDTH-1 downto 0) <= ZEROES & ramp_amp16;
               ramp_dat(ramp_dat'left)                    <= '1';                            -- next operation flag is set to subtraction    
            else
               ramp_dat(FSFB_QUEUE_DATA_WIDTH-1 downto 0) <= ZEROES & result_reg;
               ramp_dat(ramp_dat'left)                    <= '0';                            -- next operation flag is set to addition
            end if;
         end if;
         
         -- Subtract operation was performed
         -- Check lower bound >= 0
         if (add_sub_n = '0') then
            if (result_reg(result_reg'left) = '1' or 
               result_reg = ZEROES16) then
               ramp_dat(FSFB_QUEUE_DATA_WIDTH-1 downto 0) <= ZEROES & ZEROES16;              -- next operation flag is set to addition
               ramp_dat(ramp_dat'left)                    <= '0'; 
            else
               ramp_dat(FSFB_QUEUE_DATA_WIDTH-1 downto 0) <= ZEROES & result_reg;      
               ramp_dat(ramp_dat'left)                    <= '1';                            -- next operation flag is set to subtraction 
            end if;
         end if;          
      end if;
   end process comparator;

   
   -- Create delayed versions of the previous_fsfb_dat_rdy_i
   pre_fsfb_dat_rdy_delays : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         pre_fsfb_dat_rdy_1d <= '0';
         pre_fsfb_dat_rdy_2d <= '0';
      elsif (clk_50_i'event and clk_50_i = '1') then
         pre_fsfb_dat_rdy_1d <= previous_fsfb_dat_rdy_i;
         pre_fsfb_dat_rdy_2d <= pre_fsfb_dat_rdy_1d;            
      end if;
   end process pre_fsfb_dat_rdy_delays;

   
   -- Pulse to update queue with new ramp result
   ramp_update <= pre_fsfb_dat_rdy_2d;
 
 
   -- Output result only when ramp_mode is enabled
   fsfb_proc_ramp_update_o <= ramp_update when ramp_mode_en_i = '1' else '0';
   fsfb_proc_ramp_dat_o    <= ramp_dat;

  
end rtl;
