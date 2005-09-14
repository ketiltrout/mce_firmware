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
-- fsfb_processor.vhd
--
-- Project:   SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- First stage feedback calculation processor firmware
--
-- This block contains the arithmetic/comparison circuitry that calculates the results of first 
-- stage feedback to be written to the first stage feedback queue.
--
-- Instantiates two sub-components:
-- 1) fsfb_proc_pidz (lock mode processing)
-- 2) fsfb_proc_ramp (ramp mode processing)
--
-- The constant mode is taken care of at this hierarchy level.
--
--                                             
-- Revision history:
-- 
-- $Log: fsfb_processor.vhd,v $
-- Revision 1.4  2005/03/18 01:25:58  mohsen
-- Free up the constant mode from the need for adc_sample_coadd signal to be programmed.
--
-- Revision 1.3  2004/11/26 18:26:45  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/11/09 01:07:25  anthonyk
-- Added lock mode enable output.
-- Carried sign information for lock mode data output.
-- Included new generic for identifying the m.s.b. position of lock mode data output
--
-- Revision 1.1  2004/10/22 22:18:36  anthonyk
-- Initial release
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fsfb_calc_pack.all;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.fsfb_corr_pack.all;

entity fsfb_processor is
   generic (
      lock_dat_left           : integer := 30                                                 -- most significant bit position of lock mode data output, 
                                                                                              -- valid range: min = FSFB_QUEUE_DATA_WIDTH-2, max = 2*COADD_QUEUE_DATA_WIDTH
      );

   port (
      -- global signals
      rst_i                   : in     std_logic;                                             -- global reset
      clk_50_i                : in     std_logic;                                             -- global clock
    
      -- control/interface signals from upstream coadd block
      coadd_done_i            : in     std_logic;                                             -- done signal issued by coadd block to indicate coadd data valid (one-clk period pulse)
      current_coadd_dat_i     : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current coadded value 
      current_diff_dat_i      : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current difference
      current_integral_dat_i  : in     std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current integral
      
      -- control signal from io controller block
      ramp_update_new_i       : in     std_logic;                                             -- enable to latch new ramp result
      initialize_window_ext_i : in     std_logic;                                             -- ramp mode processor output would be zeroed during this window
      
      -- First stage feedback queue interface (read operation from previous queue)
      previous_fsfb_dat_rdy_i : in     std_logic;                                             -- previous data ready
      previous_fsfb_dat_i     : in     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);      -- previous data read from the previous fsfb_queue

      -- control signals from configuration registers
      servo_mode_i            : in     std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     -- servo mode selection 
      ramp_step_size_i        : in     std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          -- ramp step increments/decrements
      ramp_amp_i              : in     std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           -- ramp peak amplitude
      const_val_i             : in     std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          -- fs feedback constant value

      -- PIDZ coefficient queue interface
      p_dat_i                 : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- P,I,D,Z coefficients 
      i_dat_i                 : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      d_dat_i                 : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      --flux_quanta_dat_i       : in     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   
      -- First stage feedback queue interface (write operation to current queue)
      fsfb_proc_update_o      : out    std_logic;                                             -- update pulse to the current fsfb_queue
      fsfb_proc_dat_o         : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);      -- new data to be written to the current fsfb_queue
      
      -- First stage feedback control interface 
      flux_jumping_en_i       : in     std_logic;
      fsfb_proc_lock_en_o     : out    std_logic                                              -- fsfb_ctrl lock data mode enable
  
      );

end fsfb_processor; 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;

architecture rtl of fsfb_processor is

   -- constant declarations
   constant ZEROES             : std_logic_vector   := "00000000000000000000000";

   -- internal signal declarations
   signal const_mode_en        : std_logic;                                                    -- constant mode enable
   signal ramp_mode_en         : std_logic;                                                    -- ramp mode enable
   signal lock_mode_en         : std_logic;                                                    -- lock mode enable
   
   signal pidz_update          : std_logic;                                                    -- PIDZ lock mode result update
   signal pidz_sum             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH*2+1 downto 0);        -- PIDZ sum
   signal ramp_update          : std_logic;                                                    -- Ramp mode result update from ramp processor block
   signal ramp_update_1d       : std_logic;                                                    -- Actual ramp mode result update from fsfb processor
   signal ramp_dat             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);             -- Ramp mode processor result
   signal ramp_dat_ltch        : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);             -- Latched ramp mode processor result (fixed for configurable number of frame cycles)
   signal const_dat_ltch       : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);             -- Latched constant mode result (to created consistent timing behaviour with ramp mode result)

   signal max_range_fsfb       : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
   signal min_range_fsfb       : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
   signal pos_fsfb_clamp_value : std_logic_vector(FLUX_QUANTA_DATA_WIDTH+FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal neg_fsfb_clamp_value : std_logic_vector(FLUX_QUANTA_DATA_WIDTH+FLUX_QUANTA_CNT_WIDTH-1 downto 0);

begin

   -- Generate enable signals for different servo mode settings
   -- 00:  Invalid
   -- 01:  Constant
   const_mode_en <= not(servo_mode_i(1)) and servo_mode_i(0); 
   -- 10:  Ramp (Sawtooth)
   ramp_mode_en  <= servo_mode_i(1) and not(servo_mode_i(0));
   -- 11:  Lock 
   lock_mode_en  <= servo_mode_i(1) and servo_mode_i(0);
   
   -- Output the mode indicator to fsfb_ctrl downstream block
   fsfb_proc_lock_en_o <= lock_mode_en;
   
   -- Logic connections for update control output to the current queue
   --fsfb_proc_update_o <= (coadd_done_i and const_mode_en) or ramp_update_1d or pidz_update;
   fsfb_proc_update_o <= (previous_fsfb_dat_rdy_i and const_mode_en) or ramp_update_1d or pidz_update;
   
   -- Latch ramp mode data input with new fsfb_proc_ramp result only when 
   -- ramp_update_new_i = '1'
   ramp_dat_ltch_proc : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         ramp_dat_ltch <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (initialize_window_ext_i = '1') then
            ramp_dat_ltch <= (others => '0');
         elsif (ramp_update_new_i = '1') then
            ramp_dat_ltch <= ramp_dat;
         end if;
      end if;
   end process ramp_dat_ltch_proc;
   
   
   -- Adjust the ramp update by 1 clk cycle to account for the latch delay
   ramp_update_delay : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         ramp_update_1d <= '0';
      elsif (clk_50_i'event and clk_50_i = '1') then
         ramp_update_1d <= ramp_update;
      end if;
   end process ramp_update_delay;
   
   
   -- Latch the constant value input 
   const_dat_ltch_proc : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         const_dat_ltch <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (initialize_window_ext_i = '1') then
            const_dat_ltch <= (others => '0');
         else
            const_dat_ltch <= ZEROES & "000" & const_val_i;
         end if;
      end if;
   end process const_dat_ltch_proc;
       

   -- Muxes for update control and data output to the current queue
   fsfb_proc_mux : process (servo_mode_i, const_dat_ltch, ramp_dat_ltch, pidz_sum)--, flux_jumping_en_i, max_range_fsfb, min_range_fsfb)
   begin
      -- The most significant bit of the FSFB_QUEUE will store the flag for
      -- the next operation (add/subtract) performed in RAMP mode.  All other modes
      -- would ignore this bit setting.
      
      update_dat : case servo_mode_i is
         -- constant mode setting
         when "01"   => fsfb_proc_dat_o <= const_dat_ltch;
         
         -- ramp mode setting
         when "10"   => fsfb_proc_dat_o <= ramp_dat_ltch;

         -- lock mode setting         
         -- obtain sign bit from msb of pidz_sum and append it as bit 39 of result. 
         -- Bit 40 always gets zero as it is ignored in lock mode.  Therefore, the
         -- magnitude only covers bit 38 down to 0.
         when "11"   => fsfb_proc_dat_o <= '0' & pidz_sum(pidz_sum'left) & pidz_sum(lock_dat_left-1 downto 0);
         
         -- invalid setting
         when others => fsfb_proc_dat_o <= (others => '0');
      end case update_dat;
          
   end process fsfb_proc_mux;
   
   
   -- instance port mappings
   
   -- this block performs the lock mode operation
   i_fsfb_proc_pidz : fsfb_proc_pidz
      port map (
         rst_i                     => rst_i,                                            
         clk_50_i                  => clk_50_i,                                            
         coadd_done_i              => coadd_done_i,                                            
         current_coadd_dat_i       => current_coadd_dat_i,  
         current_diff_dat_i        => current_diff_dat_i,  
         current_integral_dat_i    => current_integral_dat_i,  
         lock_mode_en_i            => lock_mode_en,                                            
         p_dat_i                   => p_dat_i,  
         i_dat_i                   => i_dat_i,  
         d_dat_i                   => d_dat_i,  
         z_dat_i                   => (others => '0'),  
         fsfb_proc_pidz_update_o   => pidz_update,                                            
         fsfb_proc_pidz_sum_o      => pidz_sum
      );   
   
   
   -- this block performs the ramp mode operation
   i_fsfb_proc_ramp : fsfb_proc_ramp 
      port map (
         rst_i                     => rst_i,                                            
         clk_50_i                  => clk_50_i,                                          
         previous_fsfb_dat_i       => previous_fsfb_dat_i,    
         previous_fsfb_dat_rdy_i   => previous_fsfb_dat_rdy_i,                                           
         ramp_mode_en_i            => ramp_mode_en,                                            
         ramp_step_size_i          => ramp_step_size_i,         
         ramp_amp_i                => ramp_amp_i,          
         fsfb_proc_ramp_update_o   => ramp_update,                                           
         fsfb_proc_ramp_dat_o      => ramp_dat
      );
   
     
  end rtl;
