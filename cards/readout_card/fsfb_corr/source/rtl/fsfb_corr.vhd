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
-- $Id: fsfb_corr.vhd,v 1.25 2011-06-02 23:14:48 mandana Exp $
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
-- Revision 1.15.2.2  2006/06/12 22:41:55  mandana
-- fixed sign-bit for fsfb_ctrl_dat_o when flux_jumping is off
--
-- Revision 1.15.2.1  2006/04/28 18:15:29  mandana
-- correct sign-bit for feedback data when windowing is in effect for lock_en =0
--
-- Revision 1.15  2006/03/24 18:35:37  bburger
-- Bryce:
-- In fsfb_corr_pack:  converted FSFB_MAX and FSFB_MIN to std_logic_vectors
-- In fsfb_corr:  removed a conv_integer call to get rid of timing violations
--
-- Revision 1.14  2006/03/22 21:33:28  mandana
-- same as rev. 1.12, the fix introduced in 1.13 for timing violations breaks down the functionality, the fix is tracked on a branch 1.12.2.1
--
-- Revision 1.13  2006/03/14 23:37:01  mandana
-- Reduced comparator widths to resolve timing violations introduced in Q5.1
--
-- Revision 1.12  2006/02/15 20:52:12  bburger
-- Bryce:  fixed a bug whereby the input from column 0 was routed to the output of all 8 columns
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
--
-- Revision 1.7  2005/10/07 21:38:07  bburger
-- Bryce:  Added a port between fsfb_io_controller and wbs_frame_data to readout flux_counts
--
-- Revision 1.6  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.5  2005/05/06 20:06:07  bburger
-- Bryce:  Bug Fix.  The fb_max and fb_min constants weren't being initialized properly.  Any integer multiplied by a fraction is zero.
--
-- Revision 1.4  2005/04/30 01:37:42  bburger
-- Bryce:  Added a second multplier and subtractor to the fsfb_corr pipeline to reduce the time required for the flux-jumping calculation.
--
-- Revision 1.3  2005/04/22 23:22:46  bburger
-- Bryce:  Fixed some bugs.  Now in working order.
--
-- Revision 1.2  2005/04/22 00:41:56  bburger
-- Bryce:  New.
--
-- Revision 1.1.2.3  2005/04/22 00:25:42  bburger
-- Bryce:  New.
--
-- Revision 1.1.2.2  2005/04/21 00:27:18  bburger
-- Bryce:  Code update.  All files compile now.
--
-- Revision 1.1.2.1  2005/04/20 00:18:43  bburger
-- Bryce:  new
--
--   
--
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
      
      servo_en0_i     : in std_logic;
      servo_en1_i     : in std_logic;
      servo_en2_i     : in std_logic;
      servo_en3_i     : in std_logic;
      servo_en4_i     : in std_logic;
      servo_en5_i     : in std_logic;
      servo_en6_i     : in std_logic;
      servo_en7_i     : in std_logic;
      
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

      ---------------------------
      fsfb_ctrl_dat0_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat1_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat2_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat3_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat4_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat5_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat6_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat7_i: in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      
      fsfb_ctrl_dat_rdy0_i : in std_logic;
      fsfb_ctrl_dat_rdy1_i : in std_logic;
      fsfb_ctrl_dat_rdy2_i : in std_logic;
      fsfb_ctrl_dat_rdy3_i : in std_logic;
      fsfb_ctrl_dat_rdy4_i : in std_logic;
      fsfb_ctrl_dat_rdy5_i : in std_logic;
      fsfb_ctrl_dat_rdy6_i : in std_logic;
      fsfb_ctrl_dat_rdy7_i : in std_logic;
      ----------------------------

      fj_count0_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count1_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count2_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count3_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count4_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count5_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count6_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count7_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      
      
      -- fsfb_ctrl interface --
      fsfb_ctrl_dat0_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat1_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat2_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat3_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat4_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat5_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat6_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat7_o: out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat_rdy_o        : out  std_logic;

      fj_count_rdy_o  : out std_logic;
      
      -- Global Signals      
      clk_i           : in std_logic;
      rst_i           : in std_logic     
   );     
end fsfb_corr;

architecture rtl of fsfb_corr is

-- MUX control constants
constant COL0 : std_logic_vector(2 downto 0) := "000";
constant COL1 : std_logic_vector(2 downto 0) := "001";
constant COL2 : std_logic_vector(2 downto 0) := "010";
constant COL3 : std_logic_vector(2 downto 0) := "011";
constant COL4 : std_logic_vector(2 downto 0) := "100";
constant COL5 : std_logic_vector(2 downto 0) := "101";
constant COL6 : std_logic_vector(2 downto 0) := "110";
constant COL7 : std_logic_vector(2 downto 0) := "111";

constant ZERO_QUANTA : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0) := (others => '0');
constant ZERO_PID    : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX -1 downto 0) := (others=>'0');

-- Control signals
signal start_corr            : std_logic;
signal rdy_clr               : std_logic;
signal column_switch1        : std_logic_vector(2 downto 0);
signal column_switch2        : std_logic_vector(2 downto 0);
signal pid_corr_rdy          : std_logic;
signal fj_count_adj_rdy      : std_logic;

signal clear_fj_col0         : std_logic;
signal clear_fj_col1         : std_logic;
signal clear_fj_col2         : std_logic;
signal clear_fj_col3         : std_logic;
signal clear_fj_col4         : std_logic;
signal clear_fj_col5         : std_logic;
signal clear_fj_col6         : std_logic;
signal clear_fj_col7         : std_logic;

-- Data-path signals
signal flux_quanta1          : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
signal flux_quanta2          : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);

signal flux_quanta1_zxt      : std_logic_vector(MULT_WIDTH-1 downto 0); -- bug fix: for unsigned parameters larger than 8191
signal flux_quanta2_zxt      : std_logic_vector(MULT_WIDTH-1 downto 0); -- bug fix: for unsigned parameters larger than 8191

signal fj_count_adj                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_temp         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj0         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj1         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj2         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj3         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj4         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj5         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj6         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_adj7         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);

signal fb_temp1              : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0);
signal fb_temp2              : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0);
signal mult_res1             : std_logic_vector(PROD_WIDTH-1 downto 0);
signal mult_res2             : std_logic_vector(PROD_WIDTH-1 downto 0);
signal mult_res1_xtnd        : std_logic_vector(SUB_WIDTH-1 downto 0);
signal mult_res2_xtnd        : std_logic_vector(SUB_WIDTH-1 downto 0);
signal sub_res1              : std_logic_vector(SUB_WIDTH-1 downto 0);
signal sub_res2              : std_logic_vector(SUB_WIDTH-1 downto 0);

-- Registers for inputs
signal flux_quanta_reg0      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg1      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg2      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg3      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg4      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg5      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg6      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg7      : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0); 

signal fj_count_reg0         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal fj_count_reg1         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal fj_count_reg2         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal fj_count_reg3         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal fj_count_reg4         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal fj_count_reg5         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal fj_count_reg6         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal fj_count_reg7         : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 

signal fb_reg0               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal fb_reg1               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal fb_reg2               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal fb_reg3               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal fb_reg4               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal fb_reg5               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal fb_reg6               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal fb_reg7               : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 

signal fsfb_ctrl_dat_rdy0    : std_logic;

-- Registers for arithmetic outputs
signal res_a_reg0            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_a_reg1            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_a_reg2            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_a_reg3            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_a_reg4            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_a_reg5            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_a_reg6            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_a_reg7            : std_logic_vector(SUB_WIDTH-1 downto 0); 

signal res_a_en0             : std_logic; 
signal res_a_en1             : std_logic; 
signal res_a_en2             : std_logic; 
signal res_a_en3             : std_logic; 
signal res_a_en4             : std_logic; 
signal res_a_en5             : std_logic; 
signal res_a_en6             : std_logic; 
signal res_a_en7             : std_logic; 

signal res_b_reg0            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b_reg1            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b_reg2            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b_reg3            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b_reg4            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b_reg5            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b_reg6            : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b_reg7            : std_logic_vector(SUB_WIDTH-1 downto 0); 

signal res_b_en0             : std_logic; 
signal res_b_en1             : std_logic; 
signal res_b_en2             : std_logic; 
signal res_b_en3             : std_logic; 
signal res_b_en4             : std_logic; 
signal res_b_en5             : std_logic; 
signal res_b_en6             : std_logic; 
signal res_b_en7             : std_logic; 

signal res_b0                : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b1                : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b2                : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b3                : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b4                : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b5                : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b6                : std_logic_vector(SUB_WIDTH-1 downto 0); 
signal res_b7                : std_logic_vector(SUB_WIDTH-1 downto 0); 

signal fj_count_new_reg0     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_new_reg1     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_new_reg2     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_new_reg3     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_new_reg4     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_new_reg5     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_new_reg6     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal fj_count_new_reg7     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);

signal fj_count_adj_en0      : std_logic;
signal fj_count_adj_en1      : std_logic;
signal fj_count_adj_en2      : std_logic;
signal fj_count_adj_en3      : std_logic;
signal fj_count_adj_en4      : std_logic;
signal fj_count_adj_en5      : std_logic;
signal fj_count_adj_en6      : std_logic;
signal fj_count_adj_en7      : std_logic;

type states is (IDLE, CALCA0, CALCA1, CALCA2, CALCA3, CALCA4, CALCA5, CALCA6, CALCA7, PAUSE1, PAUSE2, PAUSE3);                
signal present_state : states;
signal next_state    : states;

begin

   ----------------------------------------------------------------------------
   -- start_corr has been simplified so that it only looks for an assertion from channel 0.  This will ease timing.  
   -- All the other channels of fsfb_ctrl_dat_rdy0 are asserted at the same time regardless of servo_mode.
   -- If this assumption ever becomes false, then this logic will need to change as would the logic that was here before.
   --start_corr <= fsfb_ctrl_dat_rdy0 and fsfb_ctrl_dat_rdy1 and fsfb_ctrl_dat_rdy2 and fsfb_ctrl_dat_rdy3 and 
   --              fsfb_ctrl_dat_rdy4 and fsfb_ctrl_dat_rdy5 and fsfb_ctrl_dat_rdy6 and fsfb_ctrl_dat_rdy7;   
   ----------------------------------------------------------------------------
   start_corr <= fsfb_ctrl_dat_rdy0;
     
   -- Determine whether to clear flux-jumping registers on a column-by-column basis
   clear_fj_col0 <= '1' when (flux_jump_en_i = '0' or servo_en0_i = '0' or initialize_window_i = '1') else '0';
   clear_fj_col1 <= '1' when (flux_jump_en_i = '0' or servo_en1_i = '0' or initialize_window_i = '1') else '0';
   clear_fj_col2 <= '1' when (flux_jump_en_i = '0' or servo_en2_i = '0' or initialize_window_i = '1') else '0';
   clear_fj_col3 <= '1' when (flux_jump_en_i = '0' or servo_en3_i = '0' or initialize_window_i = '1') else '0';
   clear_fj_col4 <= '1' when (flux_jump_en_i = '0' or servo_en4_i = '0' or initialize_window_i = '1') else '0';
   clear_fj_col5 <= '1' when (flux_jump_en_i = '0' or servo_en5_i = '0' or initialize_window_i = '1') else '0';
   clear_fj_col6 <= '1' when (flux_jump_en_i = '0' or servo_en6_i = '0' or initialize_window_i = '1') else '0';
   clear_fj_col7 <= '1' when (flux_jump_en_i = '0' or servo_en7_i = '0' or initialize_window_i = '1') else '0';
  
   rdy_reg: process (clk_i, rst_i)
   begin
      if rst_i = '1' then
         fsfb_ctrl_dat_rdy0 <= '0';      
        elsif clk_i'event and clk_i = '1' then
         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy0 <= '0';
         else   
            fsfb_ctrl_dat_rdy0 <= fsfb_ctrl_dat_rdy0_i;
         end if;   
      end if;
   end process; -- rdy_reg   
      
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
   
   state_NS: process(start_corr, present_state)
   begin
      next_state <= present_state;
      case present_state is
         when IDLE =>
            -- start_corr is asserted one cycle after fsfb_ctrl_dat_rdy0_i, which gives this block time to register the data it needs to peform flux-jump calcs.
            if(start_corr = '1') then
               next_state <= CALCA0;
            end if;
            
         when CALCA0 =>
            next_state <= CALCA1;
         when CALCA1 =>
            next_state <= CALCA2;
         when CALCA2 =>
            next_state <= CALCA3;
         when CALCA3 =>
            next_state <= CALCA4;
         when CALCA4 =>
            next_state <= CALCA5;
         when CALCA5 =>
            next_state <= CALCA6;
         when CALCA6 =>
            next_state <= CALCA7;
         when CALCA7 =>
            next_state <= PAUSE1;
         when PAUSE1 =>
            next_state <= PAUSE2;
         when PAUSE2 =>
            next_state <= PAUSE3;
         when PAUSE3 =>
            next_state <= IDLE;
         when others =>
            next_state <= IDLE;
      end case;
   end process;

   state_out: process(present_state, start_corr, flux_jump_en_i)
   begin   
      -- Default assignments
      rdy_clr           <= '0';
      column_switch1    <= COL0;
      column_switch2    <= COL0;
      pid_corr_rdy      <= '0'; 
      fj_count_adj_rdy  <= '0';      
      
      res_a_en0         <= '0'; 
      res_a_en1         <= '0'; 
      res_a_en2         <= '0'; 
      res_a_en3         <= '0'; 
      res_a_en4         <= '0'; 
      res_a_en5         <= '0'; 
      res_a_en6         <= '0'; 
      res_a_en7         <= '0'; 

      res_b_en0         <= '0'; 
      res_b_en1         <= '0'; 
      res_b_en2         <= '0'; 
      res_b_en3         <= '0'; 
      res_b_en4         <= '0'; 
      res_b_en5         <= '0'; 
      res_b_en6         <= '0'; 
      res_b_en7         <= '0'; 

      fj_count_adj_en0         <= '0'; 
      fj_count_adj_en1         <= '0'; 
      fj_count_adj_en2         <= '0'; 
      fj_count_adj_en3         <= '0'; 
      fj_count_adj_en4         <= '0'; 
      fj_count_adj_en5         <= '0'; 
      fj_count_adj_en6         <= '0'; 
      fj_count_adj_en7         <= '0'; 

      -- Single data latency through the pipeline is 3 cycles; there are 8 data points; so 8 + 3 = 11 cycles total.
      -- Latency cycle #1: Operands asserted at multiplier1; product propagates through subtractor1; difference registered
      -- Latency cycle #2: New fj_count_temp calculated and registered
      -- Latency cycle #3: Operands asserted at multiplier2; product propagates through subtractor2; difference registeres
      case present_state is
         when IDLE =>
            column_switch1 <= COL7;
            column_switch2 <= COL7;
      -- for flux-jumping off, apply feedback without waiting for an additional 11 cycle that takes to calculate flux-jump
      -- This means that constant values can be applied with or without the 11-cycle delay if en_fb_jump= 1 or 0.
            if(start_corr = '1' and flux_jump_en_i = '0') then
               pid_corr_rdy   <= '1';
            end if;

         when CALCA0 =>
            column_switch1 <= COL0;     
            column_switch2 <= COL7;
            res_a_en0      <= '1';
         when CALCA1 =>
            rdy_clr        <= '1';
            column_switch1 <= COL1;
            column_switch2 <= COL7;
            res_a_en1      <= '1';
            fj_count_adj_en0 <= '1';
         when CALCA2 =>
            column_switch1 <= COL2;
            column_switch2 <= COL0;
            res_a_en2      <= '1';
            res_b_en0      <= '1';
            fj_count_adj_en1 <= '1';
         when CALCA3 =>
            column_switch1 <= COL3;
            column_switch2 <= COL1;
            res_a_en3      <= '1';
            res_b_en1      <= '1';
            fj_count_adj_en2 <= '1';
         when CALCA4 =>
            column_switch1 <= COL4;
            column_switch2 <= COL2;
            res_a_en4      <= '1';
            res_b_en2      <= '1';
            fj_count_adj_en3 <= '1';
         when CALCA5 => 
            column_switch1 <= COL5;
            column_switch2 <= COL3;
            res_a_en5      <= '1';
            res_b_en3      <= '1';
            fj_count_adj_en4 <= '1';
         when CALCA6 =>
            column_switch1 <= COL6;
            column_switch2 <= COL4;
            res_a_en6      <= '1';
            res_b_en4      <= '1';
            fj_count_adj_en5 <= '1';
         when CALCA7 =>
            column_switch1 <= COL7;
            column_switch2 <= COL5;
            res_a_en7      <= '1';
            res_b_en5      <= '1';
            fj_count_adj_en6 <= '1';
         when PAUSE1 =>
            column_switch1 <= COL7;
            column_switch2 <= COL6;
            res_b_en6      <= '1';
            fj_count_adj_en7 <= '1';
         when PAUSE2 =>
            column_switch1 <= COL7;
            column_switch2 <= COL7;
            res_b_en7      <= '1';
            fj_count_adj_rdy <= '1';
         when PAUSE3 => 
            column_switch1 <= COL7;
            column_switch2 <= COL7;

            -- If flux jumping is enabled, it takes a few clock cycles to calculate the correct feedback
            if(flux_jump_en_i = '1') then
               pid_corr_rdy   <= '1';
            end if;

         when others =>
      end case;
   end process;

   column_mux1 : process (column_switch1, 
                 flux_quanta_reg0, flux_quanta_reg1, flux_quanta_reg2, flux_quanta_reg3, 
                 flux_quanta_reg4, flux_quanta_reg5, flux_quanta_reg6, flux_quanta_reg7,
                 fj_count_reg0, fj_count_reg1, fj_count_reg2, fj_count_reg3, 
                 fj_count_reg4, fj_count_reg5, fj_count_reg6, fj_count_reg7,
                 fb_reg0, fb_reg1, fb_reg2, fb_reg3, 
                 fb_reg4, fb_reg5, fb_reg6, fb_reg7)
   begin
      col_mux1: case column_switch1 is
         when COL0 => flux_quanta1 <= flux_quanta_reg0;
                      fj_count_adj <= fj_count_reg0;
                      fb_temp1     <= fb_reg0;            
                      
         when COL1 => flux_quanta1 <= flux_quanta_reg1;
                      fj_count_adj <= fj_count_reg1;
                      fb_temp1     <= fb_reg1;
         
         when COL2 => flux_quanta1 <= flux_quanta_reg2;
                      fj_count_adj <= fj_count_reg2;
                      fb_temp1     <= fb_reg2;
         
         when COL3 => flux_quanta1 <= flux_quanta_reg3;
                      fj_count_adj <= fj_count_reg3;
                      fb_temp1     <= fb_reg3;
         
         when COL4 => flux_quanta1 <= flux_quanta_reg4;
                      fj_count_adj <= fj_count_reg4;
                      fb_temp1     <= fb_reg4;
         
         when COL5 => flux_quanta1 <= flux_quanta_reg5;
                      fj_count_adj <= fj_count_reg5;
                      fb_temp1     <= fb_reg5;
         
         when COL6 => flux_quanta1 <= flux_quanta_reg6;
                      fj_count_adj <= fj_count_reg6;
                      fb_temp1     <= fb_reg6;
         
         when COL7 => flux_quanta1 <= flux_quanta_reg7;
                      fj_count_adj <= fj_count_reg7;
                      fb_temp1     <= fb_reg7;
         
         when others => flux_quanta1 <= (others => '0');
                        fj_count_adj <= (others => '0');
                        fb_temp1     <= (others => '0');
         
      end case;
   end process;

   -------------------------------
   -- Arithmetic
   -------------------------------
   flux_quanta1_zxt <= ext(flux_quanta1, MULT_WIDTH);
   mult1 : fsfb_corr_multiplier
      port map (
         dataa  => flux_quanta1_zxt,
         datab  => fj_count_adj,
         result => mult_res1
      );
   
   mult_res1_xtnd <= sxt(mult_res1, SUB_WIDTH);
   
   sub1 : fsfb_corr_subtractor
      port map (
         dataa  => fb_temp1,
         datab  => mult_res1_xtnd,
         result => sub_res1
      );

   --------------------------------------------------------
   register_result_a: process(clk_i, rst_i)
   begin    
      if(rst_i = '1') then         
         res_a_reg0 <= (others => '0'); 
         res_a_reg1 <= (others => '0'); 
         res_a_reg2 <= (others => '0'); 
         res_a_reg3 <= (others => '0'); 
         res_a_reg4 <= (others => '0'); 
         res_a_reg5 <= (others => '0'); 
         res_a_reg6 <= (others => '0'); 
         res_a_reg7 <= (others => '0'); 
      elsif(clk_i'event and clk_i = '1') then         
         if(res_a_en0 = '1') then
            res_a_reg0 <= sub_res1; 
         end if;
         if(res_a_en1 = '1') then
            res_a_reg1 <= sub_res1; 
         end if;
         if(res_a_en2 = '1') then
            res_a_reg2 <= sub_res1; 
         end if;
         if(res_a_en3 = '1') then
            res_a_reg3 <= sub_res1; 
         end if;
         if(res_a_en4 = '1') then
            res_a_reg4 <= sub_res1; 
         end if;
         if(res_a_en5 = '1') then
            res_a_reg5 <= sub_res1; 
         end if;
         if(res_a_en6 = '1') then
            res_a_reg6 <= sub_res1; 
         end if;
         if(res_a_en7 = '1') then
            res_a_reg7 <= sub_res1; 
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   -- FSFB clamping is now implemented in coadd_manager_data_path, but flux-jump counter clamping has been left here to retain the same behaviour.
   -- The flux_quanta_reg0 /= ZERO_QUANTA condition is to avoid winding up the flux counter if the flx_quanta values are zero.
   fj_count_adj0 <=
      fj_count_reg0 - 1 when (signed(res_a_reg0) < signed(FSFB_MIN)) and (fj_count_reg0 /= M_MIN) and (flux_quanta_reg0 /= ZERO_QUANTA) else
      fj_count_reg0 + 1 when (signed(res_a_reg0) > signed(FSFB_MAX)) and (fj_count_reg0 /= M_MAX) and (flux_quanta_reg0 /= ZERO_QUANTA) else
      fj_count_reg0;

   fj_count_adj1 <=
      fj_count_reg1 - 1 when (signed(res_a_reg1) < signed(FSFB_MIN)) and (fj_count_reg1 /= M_MIN) and (flux_quanta_reg1 /= ZERO_QUANTA) else 
      fj_count_reg1 + 1 when (signed(res_a_reg1) > signed(FSFB_MAX)) and (fj_count_reg1 /= M_MAX) and (flux_quanta_reg1 /= ZERO_QUANTA) else 
      fj_count_reg1;

   fj_count_adj2 <=
      fj_count_reg2 - 1 when (signed(res_a_reg2) < signed(FSFB_MIN)) and (fj_count_reg2 /= M_MIN) and (flux_quanta_reg2 /= ZERO_QUANTA) else 
      fj_count_reg2 + 1 when (signed(res_a_reg2) > signed(FSFB_MAX)) and (fj_count_reg2 /= M_MAX) and (flux_quanta_reg2 /= ZERO_QUANTA) else 
      fj_count_reg2;

   fj_count_adj3 <=
      fj_count_reg3 - 1 when (signed(res_a_reg3) < signed(FSFB_MIN)) and (fj_count_reg3 /= M_MIN) and (flux_quanta_reg3 /= ZERO_QUANTA) else 
      fj_count_reg3 + 1 when (signed(res_a_reg3) > signed(FSFB_MAX)) and (fj_count_reg3 /= M_MAX) and (flux_quanta_reg3 /= ZERO_QUANTA) else 
      fj_count_reg3;

   fj_count_adj4 <=
      fj_count_reg4 - 1 when (signed(res_a_reg4) < signed(FSFB_MIN)) and (fj_count_reg4 /= M_MIN) and (flux_quanta_reg4 /= ZERO_QUANTA) else 
      fj_count_reg4 + 1 when (signed(res_a_reg4) > signed(FSFB_MAX)) and (fj_count_reg4 /= M_MAX) and (flux_quanta_reg4 /= ZERO_QUANTA) else 
      fj_count_reg4;

   fj_count_adj5 <=
      fj_count_reg5 - 1 when (signed(res_a_reg5) < signed(FSFB_MIN)) and (fj_count_reg5 /= M_MIN) and (flux_quanta_reg5 /= ZERO_QUANTA) else 
      fj_count_reg5 + 1 when (signed(res_a_reg5) > signed(FSFB_MAX)) and (fj_count_reg5 /= M_MAX) and (flux_quanta_reg5 /= ZERO_QUANTA) else 
      fj_count_reg5;

   fj_count_adj6 <=
      fj_count_reg6 - 1 when (signed(res_a_reg6) < signed(FSFB_MIN)) and (fj_count_reg6 /= M_MIN) and (flux_quanta_reg6 /= ZERO_QUANTA) else 
      fj_count_reg6 + 1 when (signed(res_a_reg6) > signed(FSFB_MAX)) and (fj_count_reg6 /= M_MAX) and (flux_quanta_reg6 /= ZERO_QUANTA) else 
      fj_count_reg6;

   fj_count_adj7 <=
      fj_count_reg7 - 1 when (signed(res_a_reg7) < signed(FSFB_MIN)) and (fj_count_reg7 /= M_MIN) and (flux_quanta_reg7 /= ZERO_QUANTA) else 
      fj_count_reg7 + 1 when (signed(res_a_reg7) > signed(FSFB_MAX)) and (fj_count_reg7 /= M_MAX) and (flux_quanta_reg7 /= ZERO_QUANTA) else 
      fj_count_reg7;
      
   ---------------------------------------------
   m_regs: process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         fj_count_new_reg0 <= (others => '0');   
         fj_count_new_reg1 <= (others => '0');    
         fj_count_new_reg2 <= (others => '0');    
         fj_count_new_reg3 <= (others => '0');    
         fj_count_new_reg4 <= (others => '0');    
         fj_count_new_reg5 <= (others => '0');     
         fj_count_new_reg6 <= (others => '0');    
         fj_count_new_reg7 <= (others => '0');    
         
      elsif (clk_i'event and clk_i = '1') then      
         if(fj_count_adj_en0 = '1') then
            ----------------------------------------------------------------------------
            -- Bug fix #1:
            -- The "fb_reg0 /= ZERO_PID" condition was in here to initialize the flux-jumping block when the calculated PID = 0.
            -- However, this condition would have reset the flux-jumping block during zero-crossings!  Bad!
            -- Thus, the initialize_window_i interface was added to make sure that this block is only cleared when it is supposed to.
            ----------------------------------------------------------------------------
            -- Bug fix #2:
            -- Prior to this bug fix, when en_flx_jump = 1 and servo_mode = 0,1,2 spikes would appear in raw data between pixels where flx_quanta = 0, and those were flx_quanta != 0.
            -- What caused the spikes in the raw data were abrupt changes in the DAC values applied for the same value of fb_const.
            -- The fix for this was to disable flux-jumping calculations when in servo_mode = 0,1,2.
            ----------------------------------------------------------------------------
            if(clear_fj_col0 = '0') then
               fj_count_new_reg0 <= fj_count_adj0; 
            else
               fj_count_new_reg0 <= (others => '0');                
            end if;
         end if;         
         if(fj_count_adj_en1 = '1') then
            if(clear_fj_col1 = '0') then
               fj_count_new_reg1 <= fj_count_adj1; 
            else
               fj_count_new_reg1 <= (others => '0'); 
            end if;
         end if;
         if(fj_count_adj_en2 = '1') then
            if(clear_fj_col2 = '0') then
               fj_count_new_reg2 <= fj_count_adj2; 
            else
               fj_count_new_reg2 <= (others => '0'); 
            end if;
         end if;
         if(fj_count_adj_en3 = '1') then
            if(clear_fj_col3 = '0') then
               fj_count_new_reg3 <= fj_count_adj3; 
            else
               fj_count_new_reg3 <= (others => '0'); 
            end if;
         end if;
         if(fj_count_adj_en4 = '1') then
            if(clear_fj_col4 = '0') then
               fj_count_new_reg4 <= fj_count_adj4; 
            else
               fj_count_new_reg4 <= (others => '0'); 
            end if;
         end if;
         if(fj_count_adj_en5 = '1') then
            if(clear_fj_col5 = '0') then
               fj_count_new_reg5 <= fj_count_adj5; 
            else
               fj_count_new_reg5 <= (others => '0'); 
            end if;
         end if;
         if(fj_count_adj_en6 = '1') then
            if(clear_fj_col6 = '0') then
               fj_count_new_reg6 <= fj_count_adj6; 
            else
               fj_count_new_reg6 <= (others => '0'); 
            end if;
         end if;
         if(fj_count_adj_en7 = '1') then
            if(clear_fj_col7 = '0') then
               fj_count_new_reg7 <= fj_count_adj7; 
            else
               fj_count_new_reg7 <= (others => '0'); 
            end if;
         end if;
      end if;   
   end process;      

   column_mux2 : process (column_switch2,
                 flux_quanta_reg0, flux_quanta_reg1, flux_quanta_reg2, flux_quanta_reg3, 
                 flux_quanta_reg4, flux_quanta_reg5, flux_quanta_reg6, flux_quanta_reg7,
                 fj_count_new_reg0, fj_count_new_reg1, fj_count_new_reg2, fj_count_new_reg3, 
                 fj_count_new_reg4, fj_count_new_reg5, fj_count_new_reg6, fj_count_new_reg7,
                 fb_reg0, fb_reg1, fb_reg2, fb_reg3, 
                 fb_reg4, fb_reg5, fb_reg6, fb_reg7)
   begin
      col_mux2: case column_switch2 is
         when COL0 => flux_quanta2  <= flux_quanta_reg0;
                      fj_count_temp <= fj_count_new_reg0;
                      fb_temp2      <= fb_reg0;
                      
         when COL1 => flux_quanta2  <= flux_quanta_reg1;
                      fj_count_temp <= fj_count_new_reg1;
                      fb_temp2      <= fb_reg1;
                              
         when COL2 => flux_quanta2  <= flux_quanta_reg2;
                      fj_count_temp <= fj_count_new_reg2;
                      fb_temp2      <= fb_reg2;
                              
         when COL3 => flux_quanta2  <= flux_quanta_reg3;
                      fj_count_temp <= fj_count_new_reg3;
                      fb_temp2      <= fb_reg3;
                               
         when COL4 => flux_quanta2  <= flux_quanta_reg4;
                      fj_count_temp <= fj_count_new_reg4;
                      fb_temp2      <= fb_reg4;
                              
         when COL5 => flux_quanta2  <= flux_quanta_reg5;
                      fj_count_temp <= fj_count_new_reg5;
                      fb_temp2      <= fb_reg5;
                              
         when COL6 => flux_quanta2  <= flux_quanta_reg6;
                      fj_count_temp <= fj_count_new_reg6;
                      fb_temp2      <= fb_reg6;
                              
         when COL7 => flux_quanta2  <= flux_quanta_reg7;
                      fj_count_temp <= fj_count_new_reg7;
                      fb_temp2      <= fb_reg7;     
                      
         when others => flux_quanta2  <= (others => '0');
                        fj_count_temp <= (others => '0');
                        fb_temp2      <= (others => '0');          
      end case;
   end process;
   
   -------------------------------
   -- More Arithmetic
   -------------------------------
   flux_quanta2_zxt <= ext(flux_quanta2, MULT_WIDTH);
   mult2 : fsfb_corr_multiplier
      port map (
         dataa  => flux_quanta2_zxt,
         datab  => fj_count_temp,
         result => mult_res2
      );
   
   mult_res2_xtnd <= sxt(mult_res2, SUB_WIDTH);   
   
   sub2 : fsfb_corr_subtractor
      port map (
         dataa  => fb_temp2,
         datab  => mult_res2_xtnd,
         result => sub_res2
      );
              
   --------------------------------------------- 
   -- FSFB clamping is now implemented in coadd_manager_data_path, but flux-jump counter clamping has been left here to retain the same behaviour.
   res_b0 <= FSFB_CLAMP_MIN when fj_count_new_reg0 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg0 = M_MAX else
             sub_res2;
   
   res_b1 <= FSFB_CLAMP_MIN when fj_count_new_reg1 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg1 = M_MAX else
             sub_res2;

   res_b2 <= FSFB_CLAMP_MIN when fj_count_new_reg2 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg2 = M_MAX else
             sub_res2;

   res_b3 <= FSFB_CLAMP_MIN when fj_count_new_reg3 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg3 = M_MAX else
             sub_res2;

   res_b4 <= FSFB_CLAMP_MIN when fj_count_new_reg4 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg4 = M_MAX else
             sub_res2;

   res_b5 <= FSFB_CLAMP_MIN when fj_count_new_reg5 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg5 = M_MAX else
             sub_res2;

   res_b6 <= FSFB_CLAMP_MIN when fj_count_new_reg6 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg6 = M_MAX else
             sub_res2;

   res_b7 <= FSFB_CLAMP_MIN when fj_count_new_reg7 = M_MIN else
             FSFB_CLAMP_MAX when fj_count_new_reg7 = M_MAX else
             sub_res2;

   --------------------------------------------------------
   register_result_b: process(clk_i, rst_i)
   begin      
      if(rst_i = '1') then         
         res_b_reg0 <= (others => '0'); 
         res_b_reg1 <= (others => '0'); 
         res_b_reg2 <= (others => '0'); 
         res_b_reg3 <= (others => '0'); 
         res_b_reg4 <= (others => '0'); 
         res_b_reg5 <= (others => '0'); 
         res_b_reg6 <= (others => '0'); 
         res_b_reg7 <= (others => '0');      
      elsif(clk_i'event and clk_i = '1') then         
         if(res_b_en0 = '1') then
            res_b_reg0 <= res_b0;
         end if;
         if(res_b_en1 = '1') then
            res_b_reg1 <= res_b1;         
         end if;         
         if(res_b_en2 = '1') then
            res_b_reg2 <= res_b2;         
         end if;
         if(res_b_en3 = '1') then
            res_b_reg3 <= res_b3;                  
         end if;
         if(res_b_en4 = '1') then
            res_b_reg4 <= res_b4;                  
         end if;
         if(res_b_en5 = '1') then
            res_b_reg5 <= res_b5;                  
         end if;
         if(res_b_en6 = '1') then
            res_b_reg6 <= res_b6;                  
         end if;
         if(res_b_en7 = '1') then
            res_b_reg7 <= res_b7;                  
         end if;                  
      end if;
   end process;
   
   -------------------------------
   -- Registered inputs and outputs:
   -------------------------------
   -- Case 1:
   -- If servo_en_i = '1' and flux_jump_en_i = '1' then 
   -- the SCALED pidz calculation input is used to determine whether a jump needs to occur
   -- and the corrected value is passed through to the DACs
   --
   -- Case 2:
   -- If servo_en_i = '1' and flux_jump_en_i = '0' then
   -- the SCALED pidz calculation input is passed straight through to the DACs
   --
   -- Case 3:  
   -- ***Is this causing jumps in the raw data when flx_quantas for different rows are zero and non-zero?  Yes.  Bug fix.  Flux-jumping is now ignored.
   -- If servo_en_i = '0' and flux_jump_en_i = '1' then 
   -- the UNSCALED constant value input is passed straight through to the DACs.
   --
   -- Case 4:
   -- If servo_en_i = '0' and flux_jump_en_i = '0' then 
   -- the UNSCALED constant value input is passed straight through to the DACs
   -------------------------------
   register_inputs: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
      
         flux_quanta_reg0 <= (others => '0');
         fj_count_reg0    <= (others => '0');
         fb_reg0          <= (others => '0');
         
         flux_quanta_reg1 <= (others => '0');
         fj_count_reg1    <= (others => '0');
         fb_reg1          <= (others => '0');

         flux_quanta_reg2 <= (others => '0');
         fj_count_reg2    <= (others => '0');
         fb_reg2          <= (others => '0');

         flux_quanta_reg3 <= (others => '0');
         fj_count_reg3    <= (others => '0');
         fb_reg3          <= (others => '0');

         flux_quanta_reg4 <= (others => '0');
         fj_count_reg4    <= (others => '0');
         fb_reg4          <= (others => '0');

         flux_quanta_reg5 <= (others => '0');
         fj_count_reg5    <= (others => '0');
         fb_reg5          <= (others => '0');

         flux_quanta_reg6 <= (others => '0');
         fj_count_reg6    <= (others => '0');
         fb_reg6          <= (others => '0');

         flux_quanta_reg7 <= (others => '0');
         fj_count_reg7    <= (others => '0');
         fb_reg7          <= (others => '0');
      
      elsif(clk_i'event and clk_i = '1') then
         if rdy_clr = '0' then
            ---------------------------------------------------------------------------------------
            -- fsfb_ctrl_dat_rdy0_i is asserted one cycle before start_corr (AKA fsfb_ctrl_dat_rdy0).
            -- This means that flux_quanta_reg0, fj_count_reg0, and fb_reg0 are ready when start_corr is asserted.
            -- This means that we can use start_corr (AKA fsfb_ctrl_dat_rdy0) to trigger the bypass, 
            -- but we can't use fsfb_ctrl_dat_rdy0_i because fb_reg0 wouldn't be ready.
            ---------------------------------------------------------------------------------------
            if (fsfb_ctrl_dat_rdy0_i = '1') then
               flux_quanta_reg0 <= flux_quanta0_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg0    <= fj_count0_i;               
               ---------------------------------------------------------------------------------------
               -- Scaling occurs here if servo_en0_i = '1'
               -- Scaling divides the PID-loop result by 2^LSB_WINDOW_INDEX using the window implemented below.
               -- Flux-jumping is enabled/disabled later on based on both servo_en0_i and flux_jump_en_i
               ---------------------------------------------------------------------------------------
               if(servo_en0_i = '1') then
                  fb_reg0 <= fsfb_ctrl_dat0_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else       
                  fb_reg0 <= fsfb_ctrl_dat0_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;
            end if; -- rdy0
         
            if(fsfb_ctrl_dat_rdy1_i = '1') then
               flux_quanta_reg1 <= flux_quanta1_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg1           <= fj_count1_i;
               if(servo_en1_i = '1') then
                  fb_reg1 <= fsfb_ctrl_dat1_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else
                  fb_reg1 <= fsfb_ctrl_dat1_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;            
            end if; -- rdy1
         
            if(fsfb_ctrl_dat_rdy2_i = '1') then
               flux_quanta_reg2 <= flux_quanta2_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg2 <= fj_count2_i;
               if(servo_en2_i = '1') then
                  fb_reg2 <= fsfb_ctrl_dat2_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else
                  fb_reg2 <= fsfb_ctrl_dat2_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;
            end if; -- rdy2

            if(fsfb_ctrl_dat_rdy3_i = '1') then
               flux_quanta_reg3 <= flux_quanta3_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg3 <= fj_count3_i;
               if(servo_en3_i = '1') then
                  fb_reg3 <= fsfb_ctrl_dat3_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else
                  fb_reg3 <= fsfb_ctrl_dat3_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;
            end if; -- rdy3

            if(fsfb_ctrl_dat_rdy4_i = '1') then
               flux_quanta_reg4 <= flux_quanta4_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg4 <= fj_count4_i;
               if(servo_en4_i = '1') then
                  fb_reg4 <= fsfb_ctrl_dat4_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else
                  fb_reg4 <= fsfb_ctrl_dat4_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;
            end if; -- rdy4

            if(fsfb_ctrl_dat_rdy5_i = '1') then
               flux_quanta_reg5 <= flux_quanta5_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg5 <= fj_count5_i;
               if(servo_en5_i = '1') then
                  fb_reg5 <= fsfb_ctrl_dat5_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else
                  fb_reg5 <= fsfb_ctrl_dat5_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;
            end if; -- rdy5

            if(fsfb_ctrl_dat_rdy6_i = '1') then
               flux_quanta_reg6 <= flux_quanta6_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg6           <= fj_count6_i;
               if(servo_en6_i = '1') then
                  fb_reg6 <= fsfb_ctrl_dat6_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else
                  fb_reg6 <= fsfb_ctrl_dat6_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;
            end if; -- rdy6

            if(fsfb_ctrl_dat_rdy7_i = '1') then
               flux_quanta_reg7      <= flux_quanta7_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
               fj_count_reg7           <= fj_count7_i;
               if(servo_en7_i = '1') then
                  fb_reg7 <= fsfb_ctrl_dat7_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
               else
                  fb_reg7 <= fsfb_ctrl_dat7_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
               end if;
            end if; -- rdy7        
         end if; -- rdy_clr  
      end if; 
   end process;   
      
   ----------------------------------------------------------------------------
   -- FSFB Outputs:
   -- This is where the bypassing occurs if either flux_jump_en_i = 0 or servo_en0_i = 0
   -- Bypassing is done to prevent jumps in the feedback if flx_quanta is zero/non-zero, and if fsfb (ramp/constant mode) is greater than FSFB_MAX or smaller than FSFB_MIN
   ----------------------------------------------------------------------------
   fsfb_ctrl_dat0_o <=
      fb_reg0(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col0 = '1' else -- Bypass
      res_b_reg0(DAC_DAT_WIDTH-1 downto 0);                                 -- Flux-jumping path
   fsfb_ctrl_dat1_o <=
      fb_reg1(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col1 = '1' else
      res_b_reg1(DAC_DAT_WIDTH-1 downto 0);           
   fsfb_ctrl_dat2_o <=
      fb_reg2(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col2 = '1' else
      res_b_reg2(DAC_DAT_WIDTH-1 downto 0);           
   fsfb_ctrl_dat3_o <=
      fb_reg3(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col3 = '1' else
      res_b_reg3(DAC_DAT_WIDTH-1 downto 0);        
   fsfb_ctrl_dat4_o <=
      fb_reg4(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col4 = '1' else
      res_b_reg4(DAC_DAT_WIDTH-1 downto 0);        
   fsfb_ctrl_dat5_o <=
      fb_reg5(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col5 = '1' else
      res_b_reg5(DAC_DAT_WIDTH-1 downto 0);        
   fsfb_ctrl_dat6_o <=
      fb_reg6(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col6 = '1' else
      res_b_reg6(DAC_DAT_WIDTH-1 downto 0);        
   fsfb_ctrl_dat7_o <=
      fb_reg7(DAC_DAT_WIDTH-1 downto 0) when clear_fj_col7 = '1' else
      res_b_reg7(DAC_DAT_WIDTH-1 downto 0);        
   
   fj_count0_o <= fj_count_new_reg0;
   fj_count1_o <= fj_count_new_reg1;
   fj_count2_o <= fj_count_new_reg2;
   fj_count3_o <= fj_count_new_reg3;
   fj_count4_o <= fj_count_new_reg4;
   fj_count5_o <= fj_count_new_reg5;
   fj_count6_o <= fj_count_new_reg6;
   fj_count7_o <= fj_count_new_reg7;

   fsfb_ctrl_dat_rdy_o <= pid_corr_rdy;
   fj_count_rdy_o <= fj_count_adj_rdy;   
  
end rtl;