-- 2003 SCUBA-2 Project
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
-- $Id: fsfb_corr.vhd,v 1.26 2012-10-31 18:34:44 mandana Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
--
--
-- Revision history:
-- $Log: fsfb_corr.vhd,v $
-- Revision 1.26  2012-10-31 18:34:44  mandana
-- merged from branch to capture the new parallelized fsfb_corr with only 10 clock cycle for fb_dly when flux-jump is enabled.
--
-- Revision 1.25.2.2  2012-10-31 18:27:52  mandana
-- rewritten from pipelined for 8 channels to parallel implementation, fb_dly is now reduced to 10 (previously 18) when flux-jumping is enabled.
--
-- Revision 1.25.2.1  2012-09-07 21:01:40  mandana
-- cosmetic changes and signal renaming only
--
-- Revision 1.25  2011-06-02 23:14:48  mandana
-- added start_corr and flux_jump_en_i to the sensitivity list
--
-- Revision 1.24  2011-06-02 20:45:48  mandana
-- revert back to applying SQ1FB after 7 clock cycles when flux-jumping is off.
--
-- Revision 1.23  2010/08/04 21:46:41  bburger
-- BB:  Added two signals for zero-extending the flux-quanta parameter to fit the multiplier input that has been widened.
--
-- Revision 1.22  2010/06/17 01:07:11  bburger
-- BB: re-introduced flux-count clamping to maintain continuity of behavior between versions of firmware in the field.
--
-- Revision 1.21  2010/06/03 20:40:09  bburger
-- BB:  added an interface for initialize_window to replace faulty logic for trying to detect one
--
-- Revision 1.20  2010/06/03 00:15:21  bburger
-- BB: For some reason, the changes for the last committal were not complete!
--
-- Revision 1.19  2010/06/02 23:37:18  bburger
-- BB: moved segments of code around to make the data flow through this block much easier to follow.  It now flows from top to bottom.
--
-- Revision 1.17  2008/10/03 00:36:35  mandana
-- BB:  Removed the sticky bit in fsfb_corr.vhd, which was enabled when flux-jumping was turned on. Because the feedback is signed, the sticky bit would usually reflect the value of the 14th bit, except in situations when the number of flux quanta to jump was greater than 1 (i.e. cosmic rays, IV-curves, etc). Flux jumps are made at a maximum rate of one per frame period, so that if the First-Stage Feedback increased past the 13th bit, it would not be reflected in the feedback applied. Now it is.
--
-- Revision 1.16  2008/02/15 22:21:46  mandana
-- merged in the branch
--
-- Revision 1.15.2.7  2008/02/15 22:18:33  mandana
-- major bug fix with how fj_count_temp is calculated, refer to documentation for details of the pipeline
-- fixed the sign extension of pid_prev_reg
--
-- Revision 1.15.2.6  2007/03/22 18:14:54  mandana
-- reduced multiplier width to 14x8, because flux_quanta_width and flux_count width are fixed
-- number of DSP elements used is reduced from 16 to 4
-- reduced subtractor width to number of effective fsfb_ctrl_dat bits passed to fsfb_corr
-- converted some ifelse-structured muxes to case statements to help timing
-- reorganized parts of the code just for the sake of readability
--
-- Revision 1.15.2.5  2006/12/08 19:30:58  bburger
-- Bryce:  Added fsfb_ctrl_lock_en signals for all 8 channels so that the flux-jumping block can be controlled on a channel by channel basis.
--
-- Revision 1.15.2.4  2006/07/24 23:16:34  mandana
-- changed multiplier and subtractor width to relax timing
--
-- Revision 1.15.2.3  2006/07/05 19:34:45  mandana
-- added sign-bit correction when windowing is in effect for all channels
-- removed sign-bit correction introduced in the earlier version (it limited DAC range to half positive range!)
--
--
-- Revision 1.11  2006/02/08 21:00:55  bburger
-- Bryce:  fixed a bug that prevented the MCE from locking when flux-jumping was disabled
--
-- Revision 1.10  2006/01/17 20:27:56  bburger
-- Bryce:
-- Added unconditional else statements to convert latches to combinatorial logic
--
-- Revision 1.9  2005/11/26 04:35:33  bburger
-- Bryce:  Added a patch that allows flux jumping parameters to return to normal after a big change in pid_prev
--
-- Revision 1.8  2005/11/25 20:08:16  bburger
-- Bryce:  Adjusted fsfb_max = 7800 so that it is not too close to the actual sq1 V-I period of 6200 DA units -- & other modifications

-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library work;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;
use work.fsfb_corr_pack.all;

entity fsfb_corr is        
   port
   (
      -- fsfb_calc interface 
      flux_jump_en_i  : in std_logic;
      initialize_window_i : in std_logic;
      servo_rst_window_i  : in std_logic;
      
      servo_en0_i     : in std_logic;
      servo_en1_i     : in std_logic;
      servo_en2_i     : in std_logic;
      servo_en3_i     : in std_logic;
      servo_en4_i     : in std_logic;
      servo_en5_i     : in std_logic;
      servo_en6_i     : in std_logic;
      servo_en7_i     : in std_logic;
      
      servo_rst_dat_i : in std_logic_vector(NUM_COLS-1 downto 0);

      flux_quanta0_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta1_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta2_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta3_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta4_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta5_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta6_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta7_i  : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      
      fj_count0_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count1_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count2_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count3_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count4_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count5_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count6_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count7_i     : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 

      fsfb_ctrl_dat0_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat1_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat2_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat3_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat4_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat5_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat6_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat7_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat_rdy0_i : in std_logic;

      fj_count0_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count1_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count2_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count3_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count4_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count5_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count6_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count7_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count_rdy_o  : out std_logic;
     
      -- fsfb_ctrl interface --
      fsfb_ctrl_dat0_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat1_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat2_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat3_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat4_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat5_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat6_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat7_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat_rdy_o : out  std_logic;

      -- Global Signals      
      clk_i           : in std_logic;
      rst_i           : in std_logic     
   );     
end fsfb_corr;

architecture rtl of fsfb_corr is

constant ZERO_QUANTA : std_logic_vector(FLUX_QUANTA_DATA_WIDTH downto 0) := (others => '0');
constant ZERO_PID    : std_logic_vector(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0) := (others=>'0');

signal clear_fj_col          : std_logic_vector(NUM_COLS-1 downto 0);

signal mult_res1             : mult_res_array;
signal mult_res2             : mult_res_array;
signal mult_res1_xtnd        : sub_res_array;
signal mult_res2_xtnd        : sub_res_array;
signal sub_res1              : sub_res_array;
signal sub_res2              : sub_res_array;

-- Registers for inputs
signal flux_quanta_reg       : flux_quanta_array; 
signal flux_quanta_reg_xtnd  : flux_quanta_xtnd_array;
signal fj_count_reg          : flux_jump_count_array; 
signal fb_reg                : fsfb_dac_array;
signal fb_rdy                : std_logic;
signal fsfb_ctrl_dat_rdy0_1d : std_logic;

-- Registers for arithmetic outputs
signal res_a_reg             : sub_res_array;
signal res_a_en              : std_logic;
signal res_b_reg             : sub_res_array; 
signal res_b_en              : std_logic;
signal res_b                 : sub_res_array;
signal fj_count_new          : flux_jump_count_array;
signal fj_count_new_reg_en   : std_logic;
signal fj_count_new_reg      : flux_jump_count_array;
signal fj_count_new_rdy      : std_logic;

type states is (IDLE, CALC0, CALC1, CALC2, PAUSE);                
signal present_state : states;
signal next_state    : states;

begin
     
   -- Determine whether to clear flux-jumping registers on a column-by-column basis
   clear_fj_col(0) <= '1' when (flux_jump_en_i = '0' or servo_en0_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(0) = '1')) else '0';
   clear_fj_col(1) <= '1' when (flux_jump_en_i = '0' or servo_en1_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(1) = '1')) else '0';
   clear_fj_col(2) <= '1' when (flux_jump_en_i = '0' or servo_en2_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(2) = '1')) else '0';
   clear_fj_col(3) <= '1' when (flux_jump_en_i = '0' or servo_en3_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(3) = '1')) else '0';
   clear_fj_col(4) <= '1' when (flux_jump_en_i = '0' or servo_en4_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(4) = '1')) else '0';
   clear_fj_col(5) <= '1' when (flux_jump_en_i = '0' or servo_en5_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(5) = '1')) else '0';
   clear_fj_col(6) <= '1' when (flux_jump_en_i = '0' or servo_en6_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(6) = '1')) else '0';
   clear_fj_col(7) <= '1' when (flux_jump_en_i = '0' or servo_en7_i = '0' or initialize_window_i = '1' or (servo_rst_window_i = '1' and servo_rst_dat_i(7) = '1')) else '0';
  
   -------------------------------
   -- State machine
   -------------------------------
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process;
   
   state_NS: process(fsfb_ctrl_dat_rdy0_i, flux_jump_en_i, present_state)
   begin
      next_state <= present_state;
      case present_state is
         when IDLE =>
            if(fsfb_ctrl_dat_rdy0_i = '1' and flux_jump_en_i = '1') then
               next_state <= CALC0;
            end if;
            
         when CALC0 =>
            next_state <= CALC1;

         when CALC1 =>
            next_state <= CALC2;

         when CALC2 =>
            next_state <= PAUSE;

         when PAUSE =>
            next_state <= IDLE;

         when others =>
            next_state <= IDLE;
      end case;
   end process;

   state_out: process(present_state, fsfb_ctrl_dat_rdy0_1d, flux_jump_en_i)
   begin   
      -- Default assignments
      fb_rdy <= '0'; 
      fj_count_new_rdy <= '0';      
      fj_count_new_reg_en <= '0'; 
      res_a_en <= '0'; 
      res_b_en <= '0'; 

      case present_state is
         when IDLE =>
            -- when flux-jumping off, bypass flux-jump calculation
            -- note: fb_const values can be applied with or without the 4-cycle delay if en_fb_jump= 1 or 0.
            if(fsfb_ctrl_dat_rdy0_1d = '1' and flux_jump_en_i = '0') then
               fj_count_new_rdy <= '1'; -- so that we clear the fj_count banks when fj is off
               fb_rdy <= '1';
            end if;

         when CALC0 =>
            res_a_en <= '1';

         when CALC1 =>
            fj_count_new_reg_en <= '1';

         when CALC2 => 
            res_b_en <= '1';
            fj_count_new_rdy <= '1';

         when PAUSE => 
            if(flux_jump_en_i = '1') then
               fb_rdy <= '1';
            end if;

         when others =>
      end case;
   end process;

   -------------------------------
   -- Calculate flux-jump count as follows 
   -- j= fb - Q*fj_count
   -- fj_count_new = fj_count +/- 1 
   -------------------------------
   arithmetic_fj_count: for k in 0 to NUM_COLS-1 generate
       flux_quanta_reg_xtnd(k) <= '0' & flux_quanta_reg(k);
       mult1 : fsfb_corr_multiplier
         port map (
            dataa  => flux_quanta_reg_xtnd(k),
            datab  => fj_count_reg(k),
            result => mult_res1(k)
         );
      mult_res1_xtnd(k) <= sxt(mult_res1(k), SUB_WIDTH);

      sub1 : fsfb_corr_subtractor
         port map (
            dataa  => fb_reg(k),
            datab  => mult_res1_xtnd(k),
            result => sub_res1(k)
         );

      register_result_a: process(clk_i, rst_i)
      begin    
         if(rst_i = '1') then         
            res_a_reg(k) <= (others => '0');
         elsif(clk_i'event and clk_i = '1') then         
            if(res_a_en = '1') then
               res_a_reg(k) <= sub_res1(k);
            end if;
         end if;
      end process;
      ----------------------------------------------------------------------------
      -- FSFB clamping is now implemented in coadd_manager_data_path, but flux-jump counter clamping has been left here to retain the same behaviour.
      -- The flux_quanta_reg0 /= ZERO_QUANTA condition is to avoid winding up the flux counter if the flx_quanta values are zero.
      fj_count_new(k) <=
         fj_count_reg(k) - 1 when (signed(res_a_reg(k)) < signed(FSFB_MIN)) and (fj_count_reg(k) /= M_MIN) and (flux_quanta_reg(k) /= ZERO_QUANTA) else
         fj_count_reg(k) + 1 when (signed(res_a_reg(k)) > signed(FSFB_MAX)) and (fj_count_reg(k) /= M_MAX) and (flux_quanta_reg(k) /= ZERO_QUANTA) else
         fj_count_reg(k);
      
--      sub_res2(k) <=
--         sub_res1(k) - flux_quanta_reg_xtnd(k) when (signed(res_a_reg(k)) < signed(FSFB_MIN)) and (fj_count_reg(k) /= M_MIN) and (flux_quanta_reg(k) /= ZERO_QUANTA) else
--         sub_res1(k) - flux_quanta_reg_xtnd(k) when (signed(res_a_reg(k)) > signed(FSFB_MAX)) and (fj_count_reg(k) /= M_MAX) and (flux_quanta_reg(k) /= ZERO_QUANTA) else
--        sub_res1(k);
      
         
   end generate arithmetic_fj_count;
   --------------------------------------------------------
   -- calculate new fsfb_dac value with flux-quantum correction 
   -- fb_new = fb - Q*fj_count_new
   --------------------------------------------------------
   arithmetic_fsfb_dac_dat: for k in 0 to NUM_COLS-1 generate   
      m_regs: process(clk_i, rst_i)
      begin
         if rst_i = '1' then
            fj_count_new_reg(k) <= (others => '0');         

         elsif (clk_i'event and clk_i = '1') then      
            if(fj_count_new_reg_en = '1') then
               if(clear_fj_col(k) = '0') then
                  fj_count_new_reg(k) <= fj_count_new(k); 
               else
                  fj_count_new_reg(k) <= (others => '0');                
               end if;
            end if;         
         end if;   
      end process;      
       
      mult2 : fsfb_corr_multiplier
         port map (
            dataa  => flux_quanta_reg_xtnd(k),
            datab  => fj_count_new_reg(k), 
            result => mult_res2(k)
         );
      mult_res2_xtnd(k) <= sxt(mult_res2(k), SUB_WIDTH);   

      sub2 : fsfb_corr_subtractor
         port map (
            dataa  => fb_reg(k),
            datab  => mult_res2_xtnd(k),
            result => sub_res2(k)
         );

      -- clamp flux-jump count
      res_b(k) <= FSFB_CLAMP_MIN when fj_count_new_reg(k) = M_MIN else
                  FSFB_CLAMP_MAX when fj_count_new_reg(k) = M_MAX else
                  sub_res2(k);
   
      register_result_b: process(clk_i, rst_i)
      begin      
         if(rst_i = '1') then         
            res_b_reg(k) <= (others => '0'); --7
         elsif(clk_i'event and clk_i = '1') then         
            if(res_b_en = '1') then
               res_b_reg(k) <= res_b(k);
            end if;
         end if;
      end process;
      
   end generate arithmetic_fsfb_dac_dat;
   
   -------------------------------
   -- Register inputs and outputs:
   -------------------------------
   -- If servo_en_i = '1' and flux_jump_en_i = '1': use SCALED pidz result (input) to calculate flux-jump and pass the corrected value to the DACs
   -- If servo_en_i = '0'                        ': pass the UNSCALED constant value (fb_cosnt) input straight to the DACs.
   -------------------------------
   register_inputs: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         fsfb_ctrl_dat_rdy0_1d <= '0';

         flux_quanta_reg(0) <= (others => '0');
         flux_quanta_reg(1) <= (others => '0');
         flux_quanta_reg(2) <= (others => '0');
         flux_quanta_reg(3) <= (others => '0');
         flux_quanta_reg(4) <= (others => '0');
         flux_quanta_reg(5) <= (others => '0');
         flux_quanta_reg(6) <= (others => '0');
         flux_quanta_reg(7) <= (others => '0');

         fj_count_reg(0)    <= (others => '0');
         fj_count_reg(1)    <= (others => '0');
         fj_count_reg(2)    <= (others => '0');
         fj_count_reg(3)    <= (others => '0');
         fj_count_reg(4)    <= (others => '0');
         fj_count_reg(5)    <= (others => '0');
         fj_count_reg(6)    <= (others => '0');
         fj_count_reg(7)    <= (others => '0');

         fb_reg(0)          <= (others => '0');
         fb_reg(1)          <= (others => '0');
         fb_reg(2)          <= (others => '0');
         fb_reg(3)          <= (others => '0');
         fb_reg(4)          <= (others => '0');
         fb_reg(5)          <= (others => '0');
         fb_reg(6)          <= (others => '0');
         fb_reg(7)          <= (others => '0');

      elsif(clk_i'event and clk_i = '1') then
         
         fsfb_ctrl_dat_rdy0_1d <= fsfb_ctrl_dat_rdy0_i;      
         
         if (fsfb_ctrl_dat_rdy0_i = '1') then
            flux_quanta_reg(0) <= flux_quanta0_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
            flux_quanta_reg(1) <= flux_quanta1_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
            flux_quanta_reg(2) <= flux_quanta2_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
            flux_quanta_reg(3) <= flux_quanta3_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
            flux_quanta_reg(4) <= flux_quanta4_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
            flux_quanta_reg(5) <= flux_quanta5_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
            flux_quanta_reg(6) <= flux_quanta6_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
            flux_quanta_reg(7) <= flux_quanta7_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
          
            fj_count_reg(0) <= fj_count0_i; 
            fj_count_reg(1) <= fj_count1_i;
            fj_count_reg(2) <= fj_count2_i;
            fj_count_reg(3) <= fj_count3_i;
            fj_count_reg(4) <= fj_count4_i;
            fj_count_reg(5) <= fj_count5_i;
            fj_count_reg(6) <= fj_count6_i;
            fj_count_reg(7) <= fj_count7_i;

            if(servo_en0_i = '1') then
-- simulation only               fb_reg(0) <= fsfb_ctrl_dat0_i(FSFB_QUEUE_DATA_WIDTH-8 downto LSB_WINDOW_INDEX-7);
               fb_reg(0) <= fsfb_ctrl_dat0_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else       
               fb_reg(0) <= fsfb_ctrl_dat0_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;

            if(servo_en1_i = '1') then
               fb_reg(1) <= fsfb_ctrl_dat1_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               fb_reg(1) <= fsfb_ctrl_dat1_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;            
            if(servo_en2_i = '1') then
               fb_reg(2) <= fsfb_ctrl_dat2_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               fb_reg(2) <= fsfb_ctrl_dat2_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;

            if(servo_en3_i = '1') then
               fb_reg(3) <= fsfb_ctrl_dat3_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               fb_reg(3) <= fsfb_ctrl_dat3_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;

            if(servo_en4_i = '1') then
               fb_reg(4) <= fsfb_ctrl_dat4_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               fb_reg(4) <= fsfb_ctrl_dat4_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;

            if(servo_en5_i = '1') then
               fb_reg(5) <= fsfb_ctrl_dat5_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               fb_reg(5) <= fsfb_ctrl_dat5_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;

            if(servo_en6_i = '1') then
               fb_reg(6) <= fsfb_ctrl_dat6_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               fb_reg(6) <= fsfb_ctrl_dat6_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;

            if(servo_en7_i = '1') then
               fb_reg(7) <= fsfb_ctrl_dat7_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               fb_reg(7) <= fsfb_ctrl_dat7_i(FSFB_QUEUE_DATA_WIDTH- LSB_WINDOW_INDEX- 1 downto 0);
            end if;
         end if; -- fsfb_ctrl_dat_rdy0_i   
      end if; 
   end process;   
      
   ----------------------------------------------------------------------------
   -- DAC Outputs:bypass flux-jump correction when either flux_jump_en_i = 0 or servo_en0_i = 0
   -- Bypassing is done to prevent jumps in the feedback if flx_quanta is zero/non-zero, and if fsfb (ramp/constant mode) is greater than FSFB_MAX or smaller than FSFB_MIN
   ----------------------------------------------------------------------------
   fsfb_ctrl_dat0_o <= fb_reg(0)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(0) = '1' else -- Bypass
                       res_b_reg(0)(DAC_DAT_WIDTH-1 downto 0);                             -- Flux-jumping path
      
   fsfb_ctrl_dat1_o <= fb_reg(1)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(1) = '1' else
                       res_b_reg(1)(DAC_DAT_WIDTH-1 downto 0);           
   
   fsfb_ctrl_dat2_o <= fb_reg(2)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(2) = '1' else
                       res_b_reg(2)(DAC_DAT_WIDTH-1 downto 0);           

   fsfb_ctrl_dat3_o <= fb_reg(3)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(3) = '1' else
                       res_b_reg(3)(DAC_DAT_WIDTH-1 downto 0);        
                 
   fsfb_ctrl_dat4_o <= fb_reg(4)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(4) = '1' else
                       res_b_reg(4)(DAC_DAT_WIDTH-1 downto 0);        

   fsfb_ctrl_dat5_o <= fb_reg(5)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(5) = '1' else
                       res_b_reg(5)(DAC_DAT_WIDTH-1 downto 0);        

   fsfb_ctrl_dat6_o <= fb_reg(6)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(6) = '1' else
                       res_b_reg(6)(DAC_DAT_WIDTH-1 downto 0);        

   fsfb_ctrl_dat7_o <= fb_reg(7)(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col(7) = '1' else
                       res_b_reg(7)(DAC_DAT_WIDTH-1 downto 0);        
   
   fj_count0_o <= fj_count_new_reg(0);
   fj_count1_o <= fj_count_new_reg(1);
   fj_count2_o <= fj_count_new_reg(2);
   fj_count3_o <= fj_count_new_reg(3);
   fj_count4_o <= fj_count_new_reg(4);
   fj_count5_o <= fj_count_new_reg(5);
   fj_count6_o <= fj_count_new_reg(6);
   fj_count7_o <= fj_count_new_reg(7);

   fsfb_ctrl_dat_rdy_o <= fb_rdy;
   fj_count_rdy_o <= fj_count_new_rdy;   
  
end rtl;