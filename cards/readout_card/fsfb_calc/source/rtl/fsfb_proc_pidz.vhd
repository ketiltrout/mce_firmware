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
-- fsfb_proc_pidz.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- First stage feedback calculation processor lock mode firmware
--
-- This block contains the arithmetic circuitry that calculates the first stage feedback results
-- (in lock mode) written to the first stage feedback queue.
--
-- Calculations of P*Xn+I*In+D*Dn+Z are ongoing but results are only updated (ie valid) following the 
-- coadd_done_i input signal from the upstream block.  
--
--
-- Revision history:
-- 
-- $Log: fsfb_proc_pidz.vhd,v $
-- Revision 1.2  2004/11/09 01:03:07  anthonyk
-- Various changes to increase the width of the adders from 64 to 65 (first stage) and 65 to 66 (second stage) to handle all sign, overflow and carry out situations.
--
-- Revision 1.1  2004/10/22 22:18:36  anthonyk
-- Initial release
--
--


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;

entity fsfb_proc_pidz is

   port (
      -- global signals
      rst_i                    : in     std_logic;                                            -- global reset
      clk_50_i                 : in     std_logic;                                            -- global clock
   
      -- signals from adc_sample_coadd block
      coadd_done_i             : in     std_logic;                                            -- done signal issued by coadd block to indicate coadd data valid (one-clk period pulse)
      current_coadd_dat_i      : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);  -- current coadded value
      current_diff_dat_i       : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);  -- current difference
      current_integral_dat_i   : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);  -- current integral

      -- control signals from configuration registers
      lock_mode_en_i           : in     std_logic;                                            -- lock mode enable 
       
      -- PIDZ coefficient queue interface
      p_dat_i                  : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  -- P coefficient input, to be multiplied with current coadded value
      i_dat_i                  : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  -- I coefficient input, to be multiplied with current integral
      d_dat_i                  : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  -- D coefficient input, to be multiplied with current difference
      z_dat_i                  : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  -- Z coefficient input, to be added to the three multiply results

      -- outputs from first stage feedback processor block
      fsfb_proc_pidz_update_o  : out    std_logic;                                            -- update pulse to indicate P*Xn+I*In+D*Dn+Z result is ready
      fsfb_proc_pidz_sum_o     : out    std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0) -- P*Xn+I*In+D*Dn+Z result (66 bits)
  
      );

end fsfb_proc_pidz; 


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;

architecture rtl of fsfb_proc_pidz is

   -- constant declarations
   constant ZEROES             : std_logic_vector(31 downto 0) := x"00000000";
   constant ONES               : std_logic_vector(31 downto 0) := x"11111111";

   -- internal signal declarations
   signal coadd_done_1d        : std_logic;                                                   -- coadd_done_i delayed by 1 clock cycle
   signal coadd_done_2d        : std_logic;                                                   -- coadd_done_i delayed by 2 clock cycles
   signal coadd_done_3d        : std_logic;                                                   -- coadd_done_i delayed by 3 clock cycles
   signal store_mult           : std_logic;                                                   -- clock enable to register multiplier outputs
   signal store_1st_add        : std_logic;                                                   -- clock enable to register 1st stage adder outputs
   signal store_2nd_add        : std_logic;                                                   -- clock enable to register 2nd stage adder outputs
   
   signal p_product            : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2-1 downto 0);       -- P*Xn multiplier output (64 bits)
   signal i_product            : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2-1 downto 0);       -- I*In multiplier output (64 bits)
   signal d_product            : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2-1 downto 0);       -- D*Dn multiplier output (64 bits)
   
   signal p_product_reg        : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- registered P*Xn (64 + 1 bits)
   signal i_product_reg        : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- registered I*In (64 + 1 bits)
   signal d_product_reg        : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- registered D*Dn (64 + 1 bits)
   signal z_dat_65             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- Z input extended to 65 bits
   
   signal pi_sum               : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- P*Xn+I*In adder output (65 bits)
   signal dz_sum               : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- D*Dn+Z adder output    (65 bits)

   signal pi_sum_reg           : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);       -- registered P*Xn+I*In adder output (65 + 1 bits)
   signal dz_sum_reg           : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);       -- registered D*Dn+Z adder output    (65 + 1 bits)

   
   signal pidz_sum             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);       -- (P*Xn+I*In)+(D*Dn+Z) adder output (65 + 1 bits)
   signal pidz_sum_reg         : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);       -- (P*Xn+I*In)+(D*Dn+Z) adder output (65 + 1 bits)
   
begin

   -- create delayed versions of the coadd_done_i
   coadd_done_delays : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         coadd_done_1d <= '0';
         coadd_done_2d <= '0';
         coadd_done_3d <= '0';
      elsif (clk_50_i'event and clk_50_i = '1') then
         coadd_done_1d <= coadd_done_i;
         coadd_done_2d <= coadd_done_1d;
         coadd_done_3d <= coadd_done_2d;
      end if;
   end process coadd_done_delays;
   

   -- clock enables to the multiplication and adder output registers
   store_mult    <= coadd_done_i;
   store_1st_add <= coadd_done_1d;
   store_2nd_add <= coadd_done_2d;
   

   -- Multiplication stage
   -- Consists of three multiplications done in parallel:  P*current_coadd_dat_i
   --                                                      I*current_integral_dat_i
   --                                                      D*current_diff_dat_i
   -- Inputs from adc_sample_coadd blocks are all registered
   -- P,I,D,Z coefficients are registered at the outputs of the RAM 
   -- in the 3rd clock cycle of each row (i.e. 2 clock cycles from asserted row_switch_i)
   
   -- P coefficient * current value
   i_p_coeff_mult : fsfb_calc_multiplier
      port map (
         dataa                              => p_dat_i,
         datab                              => current_coadd_dat_i,
         result                             => p_product
      );
      
   -- I coefficient * current integral
   i_i_coeff_mult : fsfb_calc_multiplier
      port map (
         dataa                              => i_dat_i,
         datab                              => current_integral_dat_i,
         result                             => i_product
      );
      
   -- D coefficient * current difference
   i_d_coeff_mult : fsfb_calc_multiplier
      port map (
         dataa                              => d_dat_i,
         datab                              => current_diff_dat_i,
         result                             => d_product
      );
      
   -- Note : extend all product_regs by 1 bit (taken from the product sign bit) 
   -- to make 65 bit adder inputs; then PI/DZ_ADD gives 65 bit adder result, 
   -- no carry or overflow will occur as the extension from extra bit covers 
   -- sufficiently the worst case (adding two most negative or postive numbers 
   -- together.
         
   -- Register all products
   -- Use as inputs to 1st stage adders
   product_regs : process (clk_50_i, rst_i)
   begin
      if (rst_i = '1') then
         p_product_reg <= (others => '0');
         i_product_reg <= (others => '0');
         d_product_reg <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (store_mult = '1') then
            p_product_reg <= p_product(p_product'left) & p_product;
            i_product_reg <= i_product(i_product'left) & i_product;
            d_product_reg <= d_product(d_product'left) & d_product;
         end if;
      end if;
   end process product_regs;


   -- Note : Then further extend pi_sum and dz_sum by 1 bit to make 66 bit adder inputs
   -- pidz sum result should now be 66 bits, where bit 66 carry sign information

   -- 1st stage addition
   -- Consists of two additions done in parallel: p_product + i_product
   --                                             d_product + z                                          
   -- Inputs are all registered
   --   
   i_pi_add : fsfb_calc_adder65
      port map (
         dataa                              => p_product_reg,
         datab                              => i_product_reg,
         result                             => pi_sum 
      );
   
   -- Sign extended z_dat_i to 64 bits 
   z_dat_65 <= '0' & ZEROES & z_dat_i when z_dat_i(z_dat_i'left)='0' else
               '1' & ONES & z_dat_i;
   
   i_dz_add : fsfb_calc_adder65
      port map (
         dataa                              => d_product_reg,
         datab                              => z_dat_65,
         result                             => dz_sum
      );
      
      
   -- 2nd stage addition
   -- Consists of one addition:  pi_sum + dz_sum
   --
   -- Inputs are all registered
   --  
   i_pidz_add : fsfb_calc_adder66
      port map (
         dataa                              => pi_sum_reg,
         datab                              => dz_sum_reg,
         result                             => pidz_sum
      );
     
   -- Register all sums
   sum_regs : process (clk_50_i, rst_i)
   begin
      if (rst_i = '1') then
         pi_sum_reg   <= (others => '0');
         dz_sum_reg   <= (others => '0');
         pidz_sum_reg <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
      
         -- 1st stage sum
         if (store_1st_add = '1') then
            pi_sum_reg <= pi_sum(pi_sum'left) & pi_sum;
            dz_sum_reg <= dz_sum(dz_sum'left) & dz_sum;
         end if;
         
         -- 2nd stage sum
         if (store_2nd_add = '1') then
            pidz_sum_reg <= pidz_sum;
         end if;
      end if;
   end process sum_regs;
   
   
   -- Output results 
   fsfb_proc_pidz_sum_o    <= pidz_sum_reg;
   fsfb_proc_pidz_update_o <= coadd_done_3d when lock_mode_en_i = '1' else '0';
      
   
end rtl;
