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
-- Project:   SCUBA-2
-- Author:        Anthony Ko/Mandana Amiri
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
-- Revision 1.14  2009/10/19 20:41:47  mandana
-- merged from filter_30000_75Hz branch to remove sticky bits in arithmetic, window filter output with FILTER_SCALE_LSB, and turn the (presumably) unnecessary correction off
--
-- Revision 1.13.2.2  2009/10/09 21:18:16  mandana
-- properly initilize bxx_product_regs
-- remove sticky bits in internal arithmetic
-- removed the "corrction", was never well understood anyway, maybe due to sticky bit removal, this is not needed anymore?!
--
-- Revision 1.13.2.1  2009/09/04 23:17:47  mandana
-- Use FILTER_SCALE_LSB to window the final output of the filter
-- Fix an indexing (maybe bug) with dropping bits between 2 biquads
--
-- Revision 1.13  2009/05/27 01:31:06  bburger
-- BB: Removed a pointless interlock that added latency.
--
-- Revision 1.12  2008/10/03 00:34:16  mandana
-- BB: Removed the z-term sign extension in fsfb_proc_pidz.vhd, and the [d-term + z-term] adder to free up DSP resources since the z-term is always = 0.
--
-- Revision 1.11  2007/03/21 17:13:00  mandana
-- removed unused wtemp_reg
--
-- Revision 1.10  2007/03/07 21:09:57  mandana
-- filter_input_width is now used to determine how many bits of pid calc results are passed to the filter
--
-- Revision 1.9  2006/08/10 21:30:42  mandana
-- *** empty log message ***
--
-- Revision 1.8  2006/07/28 17:42:13  mandana
-- introduced FILTER_GAIN_WIDTH parameter to divide by 32 between 2 filter biquads
--
-- Revision 1.7  2006/03/14 22:51:06  mandana
-- interface changes to accomodate 4-pole filter
-- registered multiplier inputs to break the timing chain and resolve timing violations introduced in Quartus 5.1 synthesis
--
-- Revision 1.6  2005/12/14 18:21:51  mandana
-- added 2-pole LPF filter functionality, the multiplier is pipelined.
--
-- Revision 1.5  2004/12/22 00:38:53  mohsen
-- completed sensitivity list
--
-- Revision 1.4  2004/12/17 00:36:49  anthonyk
-- Reduced the multiplier number to 1 due to insufficient FPGA resources.  Multiplier is now shared.
--
-- Revision 1.3  2004/11/26 18:26:45  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/11/09 01:03:07  anthonyk
-- Various changes to increase the width of the adders from 64 to 65 (first stage) and 65 to 66 (second stage) to handle all sign, overflow and carry out situations.
--
-- Revision 1.1  2004/10/22 22:18:36  anthonyk
-- Initial release
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;

entity fsfb_proc_pidz is
   generic (
      filter_lock_dat_lsb     : integer := 0                                                  -- lsb position of the pidz results fed as input to the filter
      );

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
--      z_dat_i                  : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);  -- Z coefficient input, to be added to the three multiply results
      -- Filter Coefficients
      filter_coeff0_i          : in     std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff1_i          : in     std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff2_i          : in     std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff3_i          : in     std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff4_i          : in     std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff5_i          : in     std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      wn11_dat_i               : in     std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      wn12_dat_i               : in     std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      wn21_dat_i               : in     std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      wn22_dat_i               : in     std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);      
--      b1_dat_i                 : in     std_logic_vector(FLTR_COEFF_DATA_WIDTH-1 downto 0);   -- b1 coeefficient data width for 2-pole FIR filter
--      b0_dat_i                 : in     std_logic_vector(FLTR_COEFF_DATA_WIDTH-1 downto 0);   -- b0 coeefficient data width for 2-pole FIR filter
      -- outputs from first stage feedback processor block
      wn10_dat_o               : out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      wn20_dat_o               : out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      fsfb_proc_pidz_update_o  : out    std_logic;                                            -- update pulse to indicate P*Xn+I*In+D*Dn+Z result is ready
      fsfb_proc_pidz_sum_o     : out    std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0); -- P*Xn+I*In+D*Dn+Z result (66 bits)
      
      fsfb_proc_fltr_update_o  : out    std_logic;                                            -- update pulse to indicate filter result is ready
      fsfb_proc_fltr_sum_o     : out    std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0)    -- filter result
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
   constant ZEROES                 : std_logic_vector(31 downto 0) := x"00000000";
   constant ONES                   : std_logic_vector(31 downto 0) := x"11111111";

   -- internal signal declarations  
   signal calc_shift_state         : std_logic_vector(12 downto 0);                               -- calculator shift state 
   signal store_1st_add            : std_logic;                                                   -- clock enable to register 1st stage adder outputs
   signal store_2nd_add            : std_logic;                                                   -- clock enable to register 2nd stage adder outputs
   signal store_1st_wtemp          : std_logic;                                                   -- clock enable to register wtemp output(1st filter biquad intermediate results)
   signal store_2nd_wtemp          : std_logic;                                                   -- clock enable to register wtemp output(2nd filter biquad intermediate results)
   signal store_wn10               : std_logic;                                                   -- clock enable to register wn output (1st filter biquad intermediate results)
   signal store_fltr1_tmp          : std_logic;                                                   -- clock enable to register the intermediate filter output result
   signal store_fltr1_sum          : std_logic;                                                   -- clock enable to register the filter output
   signal store_wn20               : std_logic;                                                   -- clock enable to register wn output (1st filter biquad intermediate results)
   signal store_fltr2_tmp       : std_logic;                                                   -- clock enable to register the intermediate filter output result
   signal store_fltr2_sum       : std_logic;                                                   -- clock enable to register the filter output

   signal current_coadd_dat_reg    : std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);         -- current coadded value register
   signal current_diff_dat_reg     : std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);         -- current difference register
   signal current_integral_dat_reg : std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);         -- current integral register
   
   signal multiplicand_a           : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);         -- selected coefficient multiplicand
   signal multiplicand_b           : std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);         -- selected adc_sample_coadd multiplicand
   signal multiplied_result        : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2-1 downto 0);       -- P*Xn/I*In/D*Dn selected multiplier output (64 bits)

   signal multiplicand_a_reg       : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);         -- registered multiplicand A
   signal multiplicand_b_reg       : std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);         -- registered multiplicand B

   alias  filter_b11_coef          : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) is filter_coeff0_i(FILTER_COEF_WIDTH-1 downto 0);
   alias  filter_b12_coef          : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) is filter_coeff1_i(FILTER_COEF_WIDTH-1 downto 0);
   alias  filter_b21_coef          : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) is filter_coeff2_i(FILTER_COEF_WIDTH-1 downto 0);
   alias  filter_b22_coef          : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) is filter_coeff3_i(FILTER_COEF_WIDTH-1 downto 0);
--   alias  filter_scale_lsb_vec         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) is filter_coeff4_i(FILTER_COEF_WIDTH-1 downto 0);
--   alias  filter_gain_width_vec        : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0) is filter_coeff5_i(FILTER_COEF_WIDTH-1 downto 0);
   signal filter_scale_lsb         : integer range 0 to 32 := 0;                                  -- to default to the original filter (type I) parameters
   signal filter_gain_width        : integer range 0 to 32 := 11;                                 -- to default to the original filter (type I) parameters
   
   signal p_product_reg            : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- registered P*Xn (64 + 1 bits)
   signal i_product_reg            : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- registered I*In (64 + 1 bits)
   signal d_product_reg            : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- registered D*Dn (64 + 1 bits)
   signal b11_product_reg          : std_logic_vector(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);-- registered b11*Wn11 (15 + 29 + 1 bits)
   signal b12_product_reg          : std_logic_vector(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);-- registered b12*Wn12 (15 + 29 + 1 bits)
   signal b21_product_reg          : std_logic_vector(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);-- registered b21*Wn21 (15 + 29 + 1 bits)
   signal b22_product_reg          : std_logic_vector(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);-- registered b22*Wn22 (15 + 29 + 1 bits)

--   signal z_dat_65                 : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- Z input extended to 65 bits
   
   signal pi_sum                   : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- P*Xn+I*In adder output (65 bits)
   signal dz_sum                   : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2 downto 0);         -- D*Dn+Z adder output    (65 bits)

   signal pi_sum_reg               : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);       -- registered P*Xn+I*In adder output (65 + 1 bits)
   signal dz_sum_reg               : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);       -- registered D*Dn+Z adder output    (65 + 1 bits)
  
   signal pidz_sum                 : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);       -- (P*Xn+I*In)+(D*Dn+Z) adder output (65 + 1 bits)
   signal pidz_sum_reg             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);
   signal pidz_sum_reg_shift       : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);               -- pidz calculation result that is fed to the filter
                                                                                                  -- the width is due to usage in wn=pidz_sum_reg+wtemp/2^10
   
   signal fltr1_tmp                : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-2 downto 0);          -- holds the results for wn + 2*wn1 adder output (filter biquad1)
   signal fltr1_tmp_reg            : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          -- registered wn + 2*wn1(filter biquad1)
   signal fltr1_sum                : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          -- wn + 2*wn1 + wn2 adder output  (filter biquad1)
   signal fltr1_sum_reg            : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          -- registered wn + 2*wn1 + wn2    (filter biquad1)
   signal fltr1_sum_reg_shift      : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);               -- input to the second filter biquad, the width is due to usage in wn=fltr1_sum_reg+wtemp/2^10 (filter biquad1)
   signal fltr2_tmp                : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-2 downto 0);          -- holds the results for wn + 2*wn1 adder output (filter biquad2) 
   signal fltr2_tmp_reg            : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          -- registered wn + 2*wn1 (filter biquad2)
   signal fltr2_sum                : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          -- wn + 2*wn1 + wn2 adder output (filter biquad2)
   signal fltr2_sum_reg            : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          -- registered wn + 2*wn1 + wn2 (filter biquad2)
   
   signal operand_a        : std_logic_vector(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);-- selected operand (biquad1 or biquad2) for wtemp subtractor operation 
   signal operand_b                : std_logic_vector(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);-- selected operand (biquad1 or biquad2) for wtemp subtractor operation
   signal wtemp                    : std_logic_vector(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);-- stores results for b1*wn1+b2*wn2
   signal wtemp_reg_shift          : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);                -- scaled down version with sign preserved of wtemp
   signal wtemp_reg_shift_corrected: std_logic_vector(FILTER_DLY_WIDTH-1 downto 0); 
   
   signal correction_on            : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0); 
   signal wn10                     : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
   signal wn20                     : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
   signal wn10_reg                 : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          --
   signal wn20_reg                 : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);          --
   signal wn11_shift               : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-2 downto 0);
   signal wn21_shift               : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-2 downto 0);
   signal wn12_shift               : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-2 downto 0);
   signal wn22_shift               : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-2 downto 0);
        
begin
   filter_scale_lsb  <= conv_integer(filter_coeff4_i);
   filter_gain_width <= conv_integer(filter_coeff5_i);
   
   -- create calc_shift_state to time the different operations
   calc_shift_state_proc : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         calc_shift_state <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         calc_shift_state(0)          <= coadd_done_i;
         calc_shift_state(12 downto 1) <= calc_shift_state(11 downto 0);
      end if;
   end process calc_shift_state_proc;   
     

   -- An operation SCHEDULER to set the clock enables to the adder output registers
   store_1st_add    <= calc_shift_state(4);
   store_2nd_add    <= calc_shift_state(5);
   store_1st_wtemp  <= calc_shift_state(6); -- wtemp for 1st biquad 
   store_2nd_wtemp  <= calc_shift_state(8); -- wtemp for 2nd biquad
   
   store_fltr1_tmp  <= calc_shift_state(3); -- it is not dependent on any previously calculated value, so any time is good
   store_wn10       <= calc_shift_state(7);
   store_fltr1_sum  <= calc_shift_state(8);
   
   store_fltr2_tmp  <= calc_shift_state(3); -- pipeline later/ put a mux in front of...
   store_wn20       <= calc_shift_state(9); 
   store_fltr2_sum  <= calc_shift_state(10);
   

   -- Store the operand inputs 
   -- Inputs from adc_sample_coadd blocks are only guaranteed valid when coadd_done_i is asserted.
   operand_storages : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         current_coadd_dat_reg <= (others => '0');
         current_diff_dat_reg  <= (others => '0');
         current_integral_dat_reg <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (coadd_done_i = '1') then
            current_coadd_dat_reg    <= current_coadd_dat_i;
            current_diff_dat_reg     <= current_diff_dat_i;
            current_integral_dat_reg <= current_integral_dat_i;
         end if;
      end if;
   end process operand_storages;
    
   -- sign-extend all the variables you need, why this syntax doesn't work for me??
--   fltr_b1_coef_shift <= ( (FLTR_COEF_WIDTH-1 downto 0) => FLTR_B1_COEF, others=>'0');
--   fltr_b2_coef_shift <= ( (FLTR_COEF_WIDTH-1 downto 0) => FLTR_B2_COEF, others=>'0');
   
   -- Mux the correct data operand input to the single shared multiplier 
   
   multiply_mux_in : process (current_coadd_dat_reg, p_dat_i, 
                              current_diff_dat_reg, d_dat_i,
                              current_integral_dat_reg, i_dat_i,
                              wn11_dat_i, wn12_dat_i, wn21_dat_i, wn22_dat_i,
                              filter_b11_coef, filter_b12_coef, filter_b21_coef, filter_b22_coef,
                              calc_shift_state(6 downto 0))
   begin
      operand_select : case calc_shift_state(6 downto 0) is
      
         -- P*current_coadd_dat
         when "0000001" => multiplicand_a <= p_dat_i;
                           multiplicand_b <= current_coadd_dat_reg;
                 
         -- I*current_integral_dat
         when "0000010" => multiplicand_a <= i_dat_i;
                           multiplicand_b <= current_integral_dat_reg;
                          
         -- D*current_diff_dat
         when "0000100" => multiplicand_a <= d_dat_i;
                           multiplicand_b <= current_diff_dat_reg;
         
         -- B11*Wn11
         when "0001000" => multiplicand_a(FILTER_COEF_WIDTH-1 downto 0) <= FILTER_B11_COEF;
                           multiplicand_a(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_COEF_WIDTH) <= (others => '0'); --FILTER_B11_COEF(FILTER_B11_COEF'left));
                         
                           multiplicand_b(FILTER_DLY_WIDTH-1 downto 0) <= wn11_dat_i;
                           multiplicand_b(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_DLY_WIDTH) <= (others=> wn11_dat_i(wn11_dat_i'left));         
         
         -- B12*Wn12
         when "0010000" => multiplicand_a(FILTER_COEF_WIDTH-1 downto 0) <= FILTER_B12_COEF;
                           multiplicand_a(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_COEF_WIDTH) <= (others=> '0'); --FILTER_B12_COEF(FILTER_B12_COEF'left));
                         
                           multiplicand_b(FILTER_DLY_WIDTH-1 downto 0) <= wn12_dat_i;
                           multiplicand_b(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_DLY_WIDTH) <= (others=> wn12_dat_i(wn12_dat_i'left));

         -- B21*Wn21
         when "0100000" => multiplicand_a(FILTER_COEF_WIDTH-1 downto 0) <= FILTER_B21_COEF;
                           multiplicand_a(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_COEF_WIDTH) <= (others => '0'); --FILTER_B21_COEF(FILTER_B21_COEF'left));
                         
                           multiplicand_b(FILTER_DLY_WIDTH-1 downto 0) <= wn21_dat_i;
                           multiplicand_b(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_DLY_WIDTH) <= (others=> wn21_dat_i(wn21_dat_i'left));         
         
         -- B22*Wn22
         when "1000000" => multiplicand_a(FILTER_COEF_WIDTH-1 downto 0) <= FILTER_B22_COEF;
                           multiplicand_a(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_COEF_WIDTH) <= (others=> '0'); --FILTER_B22_COEF(FILTER_B22_COEF'left));
                           
                           multiplicand_b(FILTER_DLY_WIDTH-1 downto 0) <= wn22_dat_i;
                           multiplicand_b(COEFF_QUEUE_DATA_WIDTH-1 downto FILTER_DLY_WIDTH) <= (others=> wn22_dat_i(wn22_dat_i'left));
                       
         -- Invalid
         when others => multiplicand_a <= (others => '0');
                        multiplicand_b <= (others => '0');
      
      end case operand_select;
   end process multiply_mux_in;
            

   -- Multiplication stage
   -- Consists of three multiplications done in sequence:  P*current_coadd_dat_i
   --                                                      I*current_integral_dat_i
   --                                                      D*current_diff_dat_i

   -- P,I,D,Z coefficients are registered at the outputs of the RAM 
   -- in the 3rd clock cycle of each row (i.e. 2 clock cycles from asserted row_switch_i)
   
   i_coeff_mult : fsfb_calc_multiplier
      port map (
         dataa                              => multiplicand_a_reg, --if timing problem arises
         datab                              => multiplicand_b_reg, --if timing problem arises 
         result                             => multiplied_result
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
         b11_product_reg <= (others => '0');
         b12_product_reg <= (others => '0');
         b21_product_reg <= (others => '0');
         b22_product_reg <= (others => '0');
         multiplicand_a_reg <= (others => '0');
         multiplicand_b_reg <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
      
         multiplicand_a_reg <= multiplicand_a;
         multiplicand_b_reg <= multiplicand_b;
      
         if (calc_shift_state(1) = '1') then
            p_product_reg <= multiplied_result(multiplied_result'left) & multiplied_result;
         end if;
            
         if (calc_shift_state(2) = '1') then                     
            i_product_reg <= multiplied_result(multiplied_result'left) & multiplied_result;
         end if;
         
         if (calc_shift_state(3) = '1') then
            d_product_reg <= multiplied_result(multiplied_result'left) & multiplied_result;
         end if;
         
         if (calc_shift_state(4) = '1') then
            b11_product_reg <= --multiplied_result(multiplied_result'left) & --multiplied_result(multiplied_result'left) & 
                               multiplied_result(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);
         end if;

         if (calc_shift_state(5) = '1') then
            b12_product_reg <= --multiplied_result(multiplied_result'left) & -- multiplied_result(multiplied_result'left) & 
                               multiplied_result(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);
         end if;
         
         if (calc_shift_state(6) = '1') then
            b21_product_reg <=-- multiplied_result(multiplied_result'left) & --multiplied_result(multiplied_result'left) & 
                               multiplied_result(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);
         end if;

         if (calc_shift_state(7) = '1') then
            b22_product_reg <= --multiplied_result(multiplied_result'left) & -- multiplied_result(multiplied_result'left) & 
                               multiplied_result(FILTER_DLY_WIDTH+FILTER_COEF_WIDTH downto 0);
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
--   z_dat_65 <= sxt(z_dat_i, z_dat_65'length);               
--   
--   i_dz_add : fsfb_calc_adder65
--      port map (
--         dataa                              => d_product_reg,
--         datab                              => z_dat_65,
--         result                             => dz_sum
--      );
      
      
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
   ----------------------------------------------------------------------------
   -- F I L T E R - R E L A T E D     A D D I T I O N S
   --   
   -- 1 s t   B i q u a d 
   --
   
   -- filter wtemp stage addition, this adder is shared between both biquads
   -- wtemp <= b1_product_reg + b2_product_reg;
   
   -- since b1 is negative, we incorporate the sign here, equivalently, we could use an adder here and
   -- incorporate the sign in b1.
   -- Mux the correct data operand input to the shared adder
   
   adder_mux_in : process (b11_product_reg, b12_product_reg, 
                           b21_product_reg, b22_product_reg,
                           calc_shift_state(8 downto 7))
   begin
      adder_operand_select : case calc_shift_state(8 downto 7) is
      
         -- calculate wtemp of biquad 2

         when "01" =>   operand_a <= b22_product_reg;
                        operand_b <= b21_product_reg;

         when "10" =>   operand_a <= b22_product_reg;
                        operand_b <= b21_product_reg;
                 
         -- calculate wtemp of biquad 1
         when others => operand_a <= b12_product_reg;
                        operand_b <= b11_product_reg;
                             
      end case adder_operand_select;
   end process adder_mux_in;
    
   i_wtemp_add: fsfb_calc_sub45
      port map (
         dataa                              => operand_a,
         datab                              => operand_b,
         result                             => wtemp
      );         
   
   -- wtemp_reg_shift is the scaled down version of wtemp and needs correction, add 1, 
   -- when wtemp is negative
   i_wn_correction : fsfb_calc_adder29
      port map (
         dataa                              => wtemp_reg_shift,
         datab                              => correction_on,
         result                             => wtemp_reg_shift_corrected
      );
   
   correction_on <= --"00000000000000000000000000001" when wtemp_reg_shift(wtemp_reg_shift'left)='1' else 
                    (others => '0');

   -- filter wn stage addition  (1st biquad)
   -- wn <= pidz_sum_reg(pidz_sum_reg'left) & pidz_sum_reg(FILTER_DLY_WIDTH-2 downto 0) - wtemp;
   -- extend sign bit for (input_width - delay_width +1)
   pidz_sum_reg_shift <= pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) & pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) &
                         pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) & pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) &
                         pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) & pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) &
                         pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) & pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) &
                         pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1) & 
                         pidz_sum_reg(filter_lock_dat_lsb + FILTER_INPUT_WIDTH-1 downto filter_lock_dat_lsb);
   i_wn10_sub : fsfb_calc_sub29
      port map (
         dataa                              => pidz_sum_reg_shift,
         datab                              => wtemp_reg_shift_corrected, --wtemp_reg(FILTER_FB_H_BIT downto FILTER_FB_L_BIT),
         result                             => wn10
      );
   
                    
   -- filter first stage addition  (1st biquad)
   -- fltr_tmp <= wn1_dat_i&'0' + wn2_dat_i;
   wn11_shift (FILTER_DLY_WIDTH-1 downto 0) <= wn11_dat_i(FILTER_DLY_WIDTH-2 downto 0) & '0';
   wn11_shift(FLTR_QUEUE_DATA_WIDTH-2 downto FILTER_DLY_WIDTH) <= (others => wn11_dat_i(wn11_dat_i'left));
   wn12_shift (FILTER_DLY_WIDTH-1 downto 0) <= wn12_dat_i;
   wn12_shift(FLTR_QUEUE_DATA_WIDTH-2 downto FILTER_DLY_WIDTH) <= (others => wn12_dat_i(wn12_dat_i'left));

   i_fltr1_tmp : fsfb_calc_adder31
      port map (
         dataa                              => wn11_shift,
         datab                              => wn12_shift,
         result                             => fltr1_tmp
      );

   -- filter second stage addition  (1st biquad)
   -- fltr_sum <= wn_reg + fltr_tmp_reg;
   i_fltr1_add : fsfb_calc_adder32
      port map (
         dataa                              => wn10_reg,
         datab                              => fltr1_tmp_reg,
         result                             => fltr1_sum
      );   
      
   -------------------------------------------------------------------
   -- 2 n d   B i q u a d 
   --
   
   -- filter wn stage addition  (1st biquad)
   -- wn <= fltr_sum_reg - wtemp;
   inter_stage_gain_proc : process (clk_50_i, rst_i)
   variable k :  integer:= 0;
   begin
     if (rst_i = '1') then
       fltr1_sum_reg_shift <= (others => '0');
     elsif (clk_50_i'event and clk_50_i = '1') then
       k := filter_gain_width;
       for i in 0 to FILTER_DLY_WIDTH-1 loop
         if i >= (FILTER_DLY_WIDTH + 2 - filter_gain_width) then
           fltr1_sum_reg_shift(i) <= fltr1_sum_reg(fltr1_sum_reg'left);
         else
           fltr1_sum_reg_shift(i) <= fltr1_sum_reg(k);
           k := k + 1;
         end if;
       end loop;   
     end if;
   end process inter_stage_gain_proc;
   --fltr1_sum_reg_shift(FILTER_DLY_WIDTH-1 downto FILTER_DLY_WIDTH+2-FILTER_GAIN_WIDTH) <= (others => fltr1_sum_reg(fltr1_sum_reg'left));
   --fltr1_sum_reg_shift(FLTR_QUEUE_DATA_WIDTH-1-FILTER_GAIN_WIDTH downto 0) <= fltr1_sum_reg(FLTR_QUEUE_DATA_WIDTH-1 downto FILTER_GAIN_WIDTH);
   i_wn20_sub : fsfb_calc_sub29
      port map (
         dataa                              => fltr1_sum_reg_shift,
         datab                              => wtemp_reg_shift_corrected, 
         result                             => wn20
      );
      
   -- filter first stage addition  (1st biquad)
   -- fltr_tmp <= wn1_dat_i&'0' + wn2_dat_i;
   wn21_shift (FILTER_DLY_WIDTH-1 downto 0) <= wn21_dat_i(FILTER_DLY_WIDTH-2 downto 0) & '0';
   wn21_shift(FLTR_QUEUE_DATA_WIDTH-2 downto FILTER_DLY_WIDTH) <= (others => wn21_dat_i(wn21_dat_i'left));
   wn22_shift (FILTER_DLY_WIDTH-1 downto 0) <= wn22_dat_i;
   wn22_shift(FLTR_QUEUE_DATA_WIDTH-2 downto FILTER_DLY_WIDTH) <= (others => wn22_dat_i(wn22_dat_i'left));

   i_fltr2_tmp_add : fsfb_calc_adder31
      port map (
         dataa                              => wn21_shift,
         datab                              => wn22_shift,
         result                             => fltr2_tmp  
      );

   -- filter second stage addition  (1st biquad)
   -- fltr_sum <= wn_reg + fltr_tmp_reg;
   i_fltr2_add : fsfb_calc_adder32
      port map (
         dataa                              => wn20_reg,
         datab                              => fltr2_tmp_reg,
         result                             => fltr2_sum
      );   
      
   ----------------------------------------------------------------------------
   -- Register all sums
   sum_regs : process (clk_50_i, rst_i)
   begin
      if (rst_i = '1') then
         pi_sum_reg    <= (others => '0');
         dz_sum_reg    <= (others => '0');
         pidz_sum_reg  <= (others => '0');
         wn10_reg      <= (others => '0');
         wn20_reg      <= (others => '0');         
         fltr1_tmp_reg <= (others => '0');
         fltr1_sum_reg <= (others => '0');
         fltr2_tmp_reg <= (others => '0');
         fltr2_sum_reg <= (others => '0');
         wtemp_reg_shift <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
      
         -- 1st stage sum
         if (store_1st_add = '1') then
            pi_sum_reg <= pi_sum(pi_sum'left) & pi_sum;
            dz_sum_reg <= d_product_reg(d_product_reg'left) & d_product_reg;
         end if;
         
         -- 2nd stage sum
         if (store_2nd_add = '1') then
            pidz_sum_reg <= pidz_sum;
         end if;

         -- wtemp sum biquad 1
         if (store_1st_wtemp = '1') then
            wtemp_reg_shift <= wtemp(FILTER_FB_H_BIT downto FILTER_FB_L_BIT);
         end if;

         -- wtemp sum biquad 2
         if (store_2nd_wtemp = '1') then
            wtemp_reg_shift <= wtemp(FILTER_FB_H_BIT downto FILTER_FB_L_BIT);
         end if;

         -- wn10 sum (wn of biquad 1)
         if (store_wn10 = '1') then
            wn10_reg (FILTER_DLY_WIDTH-1 downto 0) <= wn10;
            wn10_reg(FLTR_QUEUE_DATA_WIDTH-1 downto FILTER_DLY_WIDTH) <= (others => wn10(wn10'left));
         end if;

         -- filter temp sum (biquad 1)
         if (store_fltr1_tmp = '1') then
            fltr1_tmp_reg <= fltr1_tmp(fltr1_tmp'left) & fltr1_tmp;
         end if;

         -- filter output sum (yn) (biquad 1)
         if (store_fltr1_sum = '1') then
            fltr1_sum_reg <= fltr1_sum;
         end if;
         
         -- wn20 sum (wn of biquad 2)
         if (store_wn20 = '1') then
            wn20_reg (FILTER_DLY_WIDTH-1 downto 0) <= wn20;
            wn20_reg(FLTR_QUEUE_DATA_WIDTH-1 downto FILTER_DLY_WIDTH) <= (others => wn20(wn20'left));
         end if;

         -- filter temp sum (biquad 2)
         if (store_fltr2_tmp = '1') then
            fltr2_tmp_reg <= fltr2_tmp(fltr2_tmp'left) & fltr2_tmp; 
         end if;

         -- filter output sum (yn) (biquad 2)
         if (store_fltr2_sum = '1') then
            fltr2_sum_reg <= fltr2_sum;
         end if;

      end if;
   end process sum_regs;
   
   
   -- Output results 
   fsfb_proc_pidz_sum_o    <= pidz_sum_reg;
   fsfb_proc_pidz_update_o <= calc_shift_state(6) when lock_mode_en_i = '1' else '0';
--   fsfb_proc_fltr_sum_o    <= sxt(fltr2_sum_reg(fltr2_sum_reg'length-1 downto FILTER_SCALE_LSB), fltr2_sum_reg'length);
   
   filter_scale_proc : process (clk_50_i, rst_i)
   variable k : integer := 0;
   begin
     if (rst_i = '1') then
       fsfb_proc_fltr_sum_o <= (others => '0');
     elsif (clk_50_i'event and clk_50_i = '1') then
       k := filter_scale_lsb;
       for i in 0 to fsfb_proc_fltr_sum_o'length -1  loop       
         if i <= fltr2_sum_reg'length-1-filter_scale_lsb then
           fsfb_proc_fltr_sum_o(i) <= fltr2_sum_reg(k);
         else
           fsfb_proc_fltr_sum_o(i) <= fltr2_sum_reg(fltr2_sum_reg'left);                      
         end if;
         k := k + 1;
       end loop;   
     end if;
   end process filter_scale_proc;
   
   -- This had a pointless control signal choking it.
   -- The filter does alter the feedback and therefore values can be writted to regardless of being in lock mode or not.
   -- We clear the filter when servo mode changes, and when the servo is off, zero inputs effectively null the servo.
   fsfb_proc_fltr_update_o <= calc_shift_state(11); -- when lock_mode_en_i = '1' else '0';
   
   wn10_dat_o              <= wn10_reg(FILTER_DLY_WIDTH-1 downto 0);
   wn20_dat_o              <= wn20_reg(FILTER_DLY_WIDTH-1 downto 0);
end rtl;
