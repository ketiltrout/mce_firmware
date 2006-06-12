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
-- $Id: fsfb_corr.vhd,v 1.15.2.1 2006/04/28 18:15:29 mandana Exp $
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
      flux_jumping_en_i          : in std_logic;
      fsfb_ctrl_lock_en_i        : in std_logic;
      
      flux_quanta0_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta1_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta2_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta3_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta4_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta5_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta6_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta7_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      
      num_flux_quanta_prev0_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      num_flux_quanta_prev1_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      num_flux_quanta_prev2_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      num_flux_quanta_prev3_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      num_flux_quanta_prev4_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      num_flux_quanta_prev5_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      num_flux_quanta_prev6_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      num_flux_quanta_prev7_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      
      fsfb_ctrl_dat0_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat1_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat2_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat3_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat4_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat5_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat6_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat7_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      
      fsfb_ctrl_dat_rdy0_i       : in std_logic;
      fsfb_ctrl_dat_rdy1_i       : in std_logic;
      fsfb_ctrl_dat_rdy2_i       : in std_logic;
      fsfb_ctrl_dat_rdy3_i       : in std_logic;
      fsfb_ctrl_dat_rdy4_i       : in std_logic;
      fsfb_ctrl_dat_rdy5_i       : in std_logic;
      fsfb_ctrl_dat_rdy6_i       : in std_logic;
      fsfb_ctrl_dat_rdy7_i       : in std_logic;
      
      num_flux_quanta_pres0_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres1_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres2_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres3_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres4_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres5_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres6_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres7_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      
      num_flux_quanta_pres_rdy_o : out std_logic;
      
      -- fsfb_ctrl interface
      fsfb_ctrl_dat0_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat1_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat2_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat3_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat4_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat5_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat6_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat7_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat_rdy_o        : out  std_logic;
      
      -- Global Signals      
      clk_i                      : in std_logic;
      rst_i                      : in std_logic     
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

constant ZERO_QUANTA : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');

constant DATA_PATH0 : std_logic := '0';
constant DATA_PATH1 : std_logic := '1';

-- Control signals
signal start_corr            : std_logic;
signal rdy_clr               : std_logic;
signal column_switch1        : std_logic_vector(2 downto 0);
signal column_switch2        : std_logic_vector(2 downto 0);
signal pid_corr_rdy          : std_logic;
signal m_pres_rdy            : std_logic;
--signal enable_feedthrough    : std_logic;

-- Data-path signals
signal flux_quanta1          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
signal flux_quanta2          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);

signal m_prev                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_prev_sign_xtnd      : std_logic_vector(MULT_WIDTH-1 downto 0);
signal m_pres_sign_xtnd      : std_logic_vector(MULT_WIDTH-1 downto 0);
signal pid_prev_sign_xtnd1   : std_logic_vector(SUB_WIDTH-1 downto 0);
signal pid_prev_sign_xtnd2   : std_logic_vector(SUB_WIDTH-1 downto 0);
signal m_pres0               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres1               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres2               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres3               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres4               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres5               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres6               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres7               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);

signal pid_prev1             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0);
signal pid_prev2             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0);
signal mult_res1             : std_logic_vector(PROD_WIDTH-1 downto 0);
signal mult_res2             : std_logic_vector(PROD_WIDTH-1 downto 0);
signal sub_res1              : std_logic_vector(SUB_WIDTH-1 downto 0);
signal sub_res2              : std_logic_vector(SUB_WIDTH-1 downto 0);

-- Registers for inputs
signal flux_quanta_reg0      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg1      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg2      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg3      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg4      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg5      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg6      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
signal flux_quanta_reg7      : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 

signal m_prev_reg0           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal m_prev_reg1           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal m_prev_reg2           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal m_prev_reg3           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal m_prev_reg4           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal m_prev_reg5           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal m_prev_reg6           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal m_prev_reg7           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 

signal pid_prev_reg0         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal pid_prev_reg1         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal pid_prev_reg2         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal pid_prev_reg3         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal pid_prev_reg4         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal pid_prev_reg5         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal pid_prev_reg6         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal pid_prev_reg7         : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0); 
signal ZERO_PID              : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0) := (others => '0'); 

signal fsfb_ctrl_dat_rdy0    : std_logic;
signal fsfb_ctrl_dat_rdy1    : std_logic;
signal fsfb_ctrl_dat_rdy2    : std_logic;
signal fsfb_ctrl_dat_rdy3    : std_logic;
signal fsfb_ctrl_dat_rdy4    : std_logic;
signal fsfb_ctrl_dat_rdy5    : std_logic;
signal fsfb_ctrl_dat_rdy6    : std_logic;
signal fsfb_ctrl_dat_rdy7    : std_logic;

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

signal m_pres_reg0            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres_reg1            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres_reg2            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres_reg3            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres_reg4            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres_reg5            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres_reg6            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres_reg7            : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);

signal m_pres_en0             : std_logic;
signal m_pres_en1             : std_logic;
signal m_pres_en2             : std_logic;
signal m_pres_en3             : std_logic;
signal m_pres_en4             : std_logic;
signal m_pres_en5             : std_logic;
signal m_pres_en6             : std_logic;
signal m_pres_en7             : std_logic;

type states is (IDLE, CALCA0, CALCA1, CALCA2, CALCA3, CALCA4, CALCA5, CALCA6, CALCA7, PAUSE1, PAUSE2, PAUSE3);                
signal present_state : states;
signal next_state    : states;

begin

   -------------------------------
   -- Instantiations
   -------------------------------
   mult1 : fsfb_corr_multiplier
      port map (
         dataa  => flux_quanta1,
         datab  => m_prev_sign_xtnd,
         result => mult_res1
      );
      
   sub1 : fsfb_corr_subtractor
      port map (
         dataa  => pid_prev_sign_xtnd1,
         datab  => mult_res1,
         result => sub_res1
      );

   mult2 : fsfb_corr_multiplier
      port map (
         dataa  => flux_quanta2,
         datab  => m_pres_sign_xtnd,
         result => mult_res2
      );
      
   sub2 : fsfb_corr_subtractor
      port map (
         dataa  => pid_prev_sign_xtnd2,
         datab  => mult_res2,
         result => sub_res2
      );

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

   state_out: process(present_state, start_corr, flux_jumping_en_i)
   begin   
      --defaults
      rdy_clr           <= '0';
      column_switch1    <= COL0;
      column_switch2    <= COL0;
      pid_corr_rdy      <= '0'; 
      m_pres_rdy        <= '0';      
      
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

      m_pres_en0         <= '0'; 
      m_pres_en1         <= '0'; 
      m_pres_en2         <= '0'; 
      m_pres_en3         <= '0'; 
      m_pres_en4         <= '0'; 
      m_pres_en5         <= '0'; 
      m_pres_en6         <= '0'; 
      m_pres_en7         <= '0'; 

      -- Data latency through the pipeline is 3 cycles:
      -- 1. Operands asserted at multiplier1; product propagates through subtractor1; difference registered
      -- 2. New m_pres calculated and registered
      -- 3. Operands asserted at multiplier2; product propagates through subtractor2; difference registeres
      
      case present_state is
         when IDLE =>
            column_switch1 <= COL7;
            column_switch2 <= COL7;

            -- If flux jumping is disabled, the fsfb at the input to this block is passed immediately to the output 
            if(start_corr = '1' and flux_jumping_en_i = '0') then
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
            m_pres_en0      <= '1';
         when CALCA2 =>
            column_switch1 <= COL2;
            column_switch2 <= COL0;
            res_a_en2      <= '1';
            res_b_en0      <= '1';
            m_pres_en1      <= '1';
         when CALCA3 =>
            column_switch1 <= COL3;
            column_switch2 <= COL1;
            res_a_en3      <= '1';
            res_b_en1      <= '1';
            m_pres_en2      <= '1';
         when CALCA4 =>
            column_switch1 <= COL4;
            column_switch2 <= COL2;
            res_a_en4      <= '1';
            res_b_en2      <= '1';
            m_pres_en3      <= '1';
         when CALCA5 => 
            column_switch1 <= COL5;
            column_switch2 <= COL3;
            res_a_en5      <= '1';
            res_b_en3      <= '1';
            m_pres_en4      <= '1';
         when CALCA6 =>
            column_switch1 <= COL6;
            column_switch2 <= COL4;
            res_a_en6      <= '1';
            res_b_en4      <= '1';
            m_pres_en5      <= '1';
         when CALCA7 =>
            column_switch1 <= COL7;
            column_switch2 <= COL5;
            res_a_en7      <= '1';
            res_b_en5      <= '1';
            m_pres_en6      <= '1';
         when PAUSE1 =>
            column_switch1 <= COL7;
            column_switch2 <= COL6;
            res_b_en6      <= '1';
            m_pres_en7      <= '1';
         when PAUSE2 =>
            column_switch1 <= COL7;
            column_switch2 <= COL7;
            res_b_en7      <= '1';
            m_pres_rdy     <= '1';
         when PAUSE3 => 
            column_switch1 <= COL7;
            column_switch2 <= COL7;

            -- If flux jumping is enabled, it takes a few clock cycles to calculate the correct feedback
            if(flux_jumping_en_i = '1') then
               pid_corr_rdy   <= '1';
            end if;

         when others =>
      end case;
   end process;

   -------------------------------
   -- Registered aritmetic outputs
   -------------------------------
   register_result: process(clk_i, rst_i)
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

         res_b_reg0 <= (others => '0'); 
         res_b_reg1 <= (others => '0'); 
         res_b_reg2 <= (others => '0'); 
         res_b_reg3 <= (others => '0'); 
         res_b_reg4 <= (others => '0'); 
         res_b_reg5 <= (others => '0'); 
         res_b_reg6 <= (others => '0'); 
         res_b_reg7 <= (others => '0');
      
         m_pres_reg0 <= (others => '0');   
         m_pres_reg1 <= (others => '0');    
         m_pres_reg2 <= (others => '0');    
         m_pres_reg3 <= (others => '0');    
         m_pres_reg4 <= (others => '0');    
         m_pres_reg5 <= (others => '0');     
         m_pres_reg6 <= (others => '0');    
         m_pres_reg7 <= (others => '0');    

      elsif(clk_i'event and clk_i = '1') then
         
---------------------------------------------
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

---------------------------------------------
         if(res_b_en0 = '1') then
            -- If we've maxed out the number of flux jumps allowed, clamp the value
            if(m_pres_reg0 = M_MIN) then
               res_b_reg0 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg0 = M_MAX) then
               res_b_reg0 <= FSFB_CLAMP_MAX;
            else
               res_b_reg0 <= sub_res2; 
            end if;
         end if;
         if(res_b_en1 = '1') then
            if(m_pres_reg1 = M_MIN) then
               res_b_reg1 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg1 = M_MAX) then
               res_b_reg1 <= FSFB_CLAMP_MAX;
            else
               res_b_reg1 <= sub_res2; 
            end if;
         end if;
         if(res_b_en2 = '1') then
            if(m_pres_reg2 = M_MIN) then
               res_b_reg2 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg2 = M_MAX) then
               res_b_reg2 <= FSFB_CLAMP_MAX;
            else
               res_b_reg2 <= sub_res2; 
            end if;
         end if;
         if(res_b_en3 = '1') then
            if(m_pres_reg3 = M_MIN) then
               res_b_reg3 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg3 = M_MAX) then
               res_b_reg3 <= FSFB_CLAMP_MAX;
            else
               res_b_reg3 <= sub_res2; 
            end if;
         end if;
         if(res_b_en4 = '1') then
            if(m_pres_reg4 = M_MIN) then
               res_b_reg4 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg4 = M_MAX) then
               res_b_reg4 <= FSFB_CLAMP_MAX;
            else
               res_b_reg4 <= sub_res2; 
            end if;
         end if;
         if(res_b_en5 = '1') then
            if(m_pres_reg5 = M_MIN) then
               res_b_reg5 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg5 = M_MAX) then
               res_b_reg5 <= FSFB_CLAMP_MAX;
            else
               res_b_reg5 <= sub_res2; 
            end if;
         end if;
         if(res_b_en6 = '1') then
            if(m_pres_reg6 = M_MIN) then
               res_b_reg6 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg6 = M_MAX) then
               res_b_reg6 <= FSFB_CLAMP_MAX;
            else
               res_b_reg6 <= sub_res2; 
            end if;
         end if;
         if(res_b_en7 = '1') then
            if(m_pres_reg7 = M_MIN) then
               res_b_reg7 <= FSFB_CLAMP_MIN;
            elsif(m_pres_reg7 = M_MAX) then
               res_b_reg7 <= FSFB_CLAMP_MAX;
            else
               res_b_reg7 <= sub_res2; 
            end if;
         end if;
         
         -- When flux jumping is disabled, we set all the m_pres values back to 0
         -- This is what they should be if we were to re-enable the flux jumping

         if(m_pres_en0 = '1') then
            -- If we don't return to 0 after a very large pid_prev, then m_pres is not reset accordingly
            if(flux_jumping_en_i = '1' and pid_prev_reg0 /= ZERO_PID) then
               m_pres_reg0 <= m_pres0; 
            else
               m_pres_reg0 <= (others => '0'); 
            end if;
         end if;
         if(m_pres_en1 = '1') then
            if(flux_jumping_en_i = '1' and pid_prev_reg1 /= ZERO_PID) then
               m_pres_reg1 <= m_pres1; 
            else
               m_pres_reg1 <= (others => '0'); 
            end if;
         end if;
         if(m_pres_en2 = '1') then
            if(flux_jumping_en_i = '1' and pid_prev_reg2 /= ZERO_PID) then
               m_pres_reg2 <= m_pres2; 
            else
               m_pres_reg2 <= (others => '0'); 
            end if;
         end if;
         if(m_pres_en3 = '1') then
            if(flux_jumping_en_i = '1' and pid_prev_reg3 /= ZERO_PID) then
               m_pres_reg3 <= m_pres3; 
            else
               m_pres_reg3 <= (others => '0'); 
            end if;
         end if;
         if(m_pres_en4 = '1') then
            if(flux_jumping_en_i = '1' and pid_prev_reg4 /= ZERO_PID) then
               m_pres_reg4 <= m_pres4; 
            else
               m_pres_reg4 <= (others => '0'); 
            end if;
         end if;
         if(m_pres_en5 = '1') then
            if(flux_jumping_en_i = '1' and pid_prev_reg5 /= ZERO_PID) then
               m_pres_reg5 <= m_pres5; 
            else
               m_pres_reg5 <= (others => '0'); 
            end if;
         end if;
         if(m_pres_en6 = '1') then
            if(flux_jumping_en_i = '1' and pid_prev_reg6 /= ZERO_PID) then
               m_pres_reg6 <= m_pres6; 
            else
               m_pres_reg6 <= (others => '0'); 
            end if;
         end if;
         if(m_pres_en7 = '1') then
            if(flux_jumping_en_i = '1' and pid_prev_reg7 /= ZERO_PID) then
               m_pres_reg7 <= m_pres7; 
            else
               m_pres_reg7 <= (others => '0'); 
            end if;
         end if;
         
      end if;
   end process;

   -------------------------------
   -- Registered inputs
   -------------------------------
   register_inputs: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
      
         flux_quanta_reg0      <= (others => '0');
         m_prev_reg0           <= (others => '0');
         pid_prev_reg0         <= (others => '0');
         fsfb_ctrl_dat_rdy0    <= '0';
         
         flux_quanta_reg1      <= (others => '0');
         m_prev_reg1           <= (others => '0');
         pid_prev_reg1         <= (others => '0');
         fsfb_ctrl_dat_rdy1    <= '0';

         flux_quanta_reg2      <= (others => '0');
         m_prev_reg2           <= (others => '0');
         pid_prev_reg2         <= (others => '0');
         fsfb_ctrl_dat_rdy2    <= '0';

         flux_quanta_reg3      <= (others => '0');
         m_prev_reg3           <= (others => '0');
         pid_prev_reg3         <= (others => '0');
         fsfb_ctrl_dat_rdy3    <= '0';

         flux_quanta_reg4      <= (others => '0');
         m_prev_reg4           <= (others => '0');
         pid_prev_reg4         <= (others => '0');
         fsfb_ctrl_dat_rdy4    <= '0';

         flux_quanta_reg5      <= (others => '0');
         m_prev_reg5           <= (others => '0');
         pid_prev_reg5         <= (others => '0');
         fsfb_ctrl_dat_rdy5    <= '0';

         flux_quanta_reg6      <= (others => '0');
         m_prev_reg6           <= (others => '0');
         pid_prev_reg6         <= (others => '0');
         fsfb_ctrl_dat_rdy6    <= '0';

         flux_quanta_reg7      <= (others => '0');
         m_prev_reg7           <= (others => '0');
         pid_prev_reg7         <= (others => '0');
         fsfb_ctrl_dat_rdy7    <= '0';
      
      elsif(clk_i'event and clk_i = '1') then

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy0    <= '0';
         elsif(fsfb_ctrl_dat_rdy0_i = '1') then
            flux_quanta_reg0      <= flux_quanta0_i;
            m_prev_reg0           <= num_flux_quanta_prev0_i;

            ---------------------------------------------------------------------------------------
            -- In fsfb_corr, fsfb_ctrl_lock_en_i = '1' means that the servo is running, 
            -- and that scaling on fsfb_ctrl_dat0_i input data bus
            -- must occur at the input so that the servo is only as sensitive as it needs to be.
            --
            -- Case 1:
            -- If fsfb_ctrl_lock_en_i = '1' and flux_jumping_en_i = '1' then 
            -- the scaled pidz calculation input is used to determine whether a jump needs to occur
            -- and the corrected value is passed through to the DACs
            --
            -- Case 2:
            -- If fsfb_ctrl_lock_en_i = '1' and flux_jumping_en_i = '0' then
            -- the scaled pidz calculation input is passed straight through to the DACs
            --
            -- Case 3:
            -- If fsfb_ctrl_lock_en_i = '0' and flux_jumping_en_i = '1' then 
            -- the un-scaled constant value input is used to determine whether a jump needs to occur
            -- and the corrected value is passed through to the DACs
            --
            -- Case 4:
            -- If fsfb_ctrl_lock_en_i = '0' and flux_jumping_en_i = '0' then 
            -- the un-scaled constant value input is passed straight through to the DACs
            --            
            -- Currently, LSB_WINDOW_INDEX = 14, so the input is scaled down by 2^14.
            ---------------------------------------------------------------------------------------

            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg0         <= fsfb_ctrl_dat0_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg0         <= fsfb_ctrl_dat0_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy0    <= fsfb_ctrl_dat_rdy0_i;
         end if;
         
         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy1    <= '0';
         elsif(fsfb_ctrl_dat_rdy1_i = '1') then
            flux_quanta_reg1      <= flux_quanta1_i;
            m_prev_reg1           <= num_flux_quanta_prev1_i;
            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg1         <= fsfb_ctrl_dat1_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg1         <= fsfb_ctrl_dat1_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy1    <= fsfb_ctrl_dat_rdy1_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy2    <= '0';
         elsif(fsfb_ctrl_dat_rdy2_i = '1') then
            flux_quanta_reg2      <= flux_quanta2_i;
            m_prev_reg2           <= num_flux_quanta_prev2_i;
            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg2         <= fsfb_ctrl_dat2_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg2         <= fsfb_ctrl_dat2_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy2    <= fsfb_ctrl_dat_rdy2_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy3    <= '0';
         elsif(fsfb_ctrl_dat_rdy3_i = '1') then
            flux_quanta_reg3      <= flux_quanta3_i;
            m_prev_reg3           <= num_flux_quanta_prev3_i;
            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg3         <= fsfb_ctrl_dat3_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg3         <= fsfb_ctrl_dat3_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy3    <= fsfb_ctrl_dat_rdy3_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy4    <= '0';
         elsif(fsfb_ctrl_dat_rdy4_i = '1') then
            flux_quanta_reg4      <= flux_quanta4_i;
            m_prev_reg4           <= num_flux_quanta_prev4_i;
            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg4         <= fsfb_ctrl_dat4_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg4         <= fsfb_ctrl_dat4_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy4    <= fsfb_ctrl_dat_rdy4_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy5    <= '0';
         elsif(fsfb_ctrl_dat_rdy5_i = '1') then
            flux_quanta_reg5      <= flux_quanta5_i;
            m_prev_reg5           <= num_flux_quanta_prev5_i;
            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg5         <= fsfb_ctrl_dat5_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg5         <= fsfb_ctrl_dat5_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy5    <= fsfb_ctrl_dat_rdy5_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy6    <= '0';
         elsif(fsfb_ctrl_dat_rdy6_i = '1') then
            flux_quanta_reg6      <= flux_quanta6_i;
            m_prev_reg6           <= num_flux_quanta_prev6_i;
            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg6         <= fsfb_ctrl_dat6_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg6         <= fsfb_ctrl_dat6_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy6    <= fsfb_ctrl_dat_rdy6_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy7    <= '0';
         elsif(fsfb_ctrl_dat_rdy7_i = '1') then
            flux_quanta_reg7      <= flux_quanta7_i;
            m_prev_reg7           <= num_flux_quanta_prev7_i;
            if(fsfb_ctrl_lock_en_i = '1') then
               pid_prev_reg7         <= fsfb_ctrl_dat7_i(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX);
            else
               pid_prev_reg7         <= fsfb_ctrl_dat7_i(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);
            end if;
            fsfb_ctrl_dat_rdy7    <= fsfb_ctrl_dat_rdy7_i;
         end if;
         
      end if;
   end process;

   -------------------------------
   --  Combinatorial Logic (MUXes, etc)
   -------------------------------
   flux_quanta1 <=
      flux_quanta_reg0 when column_switch1 = COL0 else
      flux_quanta_reg1 when column_switch1 = COL1 else
      flux_quanta_reg2 when column_switch1 = COL2 else
      flux_quanta_reg3 when column_switch1 = COL3 else
      flux_quanta_reg4 when column_switch1 = COL4 else
      flux_quanta_reg5 when column_switch1 = COL5 else
      flux_quanta_reg6 when column_switch1 = COL6 else
      flux_quanta_reg7 when column_switch1 = COL7 else
      (others => '0');
   
   flux_quanta2 <=
      flux_quanta_reg0 when column_switch2 = COL0 else
      flux_quanta_reg1 when column_switch2 = COL1 else
      flux_quanta_reg2 when column_switch2 = COL2 else
      flux_quanta_reg3 when column_switch2 = COL3 else
      flux_quanta_reg4 when column_switch2 = COL4 else
      flux_quanta_reg5 when column_switch2 = COL5 else
      flux_quanta_reg6 when column_switch2 = COL6 else
      flux_quanta_reg7 when column_switch2 = COL7 else
      (others => '0');

   m_prev <=
      m_prev_reg0 when column_switch1 = COL0 else
      m_prev_reg1 when column_switch1 = COL1 else
      m_prev_reg2 when column_switch1 = COL2 else
      m_prev_reg3 when column_switch1 = COL3 else
      m_prev_reg4 when column_switch1 = COL4 else
      m_prev_reg5 when column_switch1 = COL5 else
      m_prev_reg6 when column_switch1 = COL6 else
      m_prev_reg7 when column_switch1 = COL7 else
      (others => '0');
      
   pid_prev1 <=
      pid_prev_reg0 when column_switch1 = COL0 else
      pid_prev_reg1 when column_switch1 = COL1 else
      pid_prev_reg2 when column_switch1 = COL2 else
      pid_prev_reg3 when column_switch1 = COL3 else
      pid_prev_reg4 when column_switch1 = COL4 else
      pid_prev_reg5 when column_switch1 = COL5 else
      pid_prev_reg6 when column_switch1 = COL6 else
      pid_prev_reg7 when column_switch1 = COL7 else
      (others => '0');
      
   pid_prev2 <=
      pid_prev_reg0 when column_switch2 = COL0 else
      pid_prev_reg1 when column_switch2 = COL1 else
      pid_prev_reg2 when column_switch2 = COL2 else
      pid_prev_reg3 when column_switch2 = COL3 else
      pid_prev_reg4 when column_switch2 = COL4 else
      pid_prev_reg5 when column_switch2 = COL5 else
      pid_prev_reg6 when column_switch2 = COL6 else
      pid_prev_reg7 when column_switch2 = COL7 else
      (others => '0');

   num_flux_quanta_pres0_o <= m_pres_reg0;
   num_flux_quanta_pres1_o <= m_pres_reg1;
   num_flux_quanta_pres2_o <= m_pres_reg2;
   num_flux_quanta_pres3_o <= m_pres_reg3;
   num_flux_quanta_pres4_o <= m_pres_reg4;
   num_flux_quanta_pres5_o <= m_pres_reg5;
   num_flux_quanta_pres6_o <= m_pres_reg6;
   num_flux_quanta_pres7_o <= m_pres_reg7;
   num_flux_quanta_pres_rdy_o <= m_pres_rdy;
   
   m_pres <=
      m_pres_reg0 when column_switch2 = COL0 else
      m_pres_reg1 when column_switch2 = COL1 else
      m_pres_reg2 when column_switch2 = COL2 else
      m_pres_reg3 when column_switch2 = COL3 else
      m_pres_reg4 when column_switch2 = COL4 else
      m_pres_reg5 when column_switch2 = COL5 else
      m_pres_reg6 when column_switch2 = COL6 else
      m_pres_reg7 when column_switch2 = COL7 else
      (others => '0');
      
   -- start_corr relies on the fact that all 8 fsfb_io_controllers assert their rdy signal at the same time, otherwise this statement will not work
   start_corr <= 
      fsfb_ctrl_dat_rdy0 and
      fsfb_ctrl_dat_rdy1 and
      fsfb_ctrl_dat_rdy2 and
      fsfb_ctrl_dat_rdy3 and
      fsfb_ctrl_dat_rdy4 and
      fsfb_ctrl_dat_rdy5 and
      fsfb_ctrl_dat_rdy6 and
      fsfb_ctrl_dat_rdy7;
   
   --enable_feedthrough <= '1' when flux_jumping_en_i = '0' else '0'; --and fsfb_ctrl_lock_en_i = '1' 
      
   m_prev_sign_xtnd <= sign_xtnd_m(m_prev);
   m_pres_sign_xtnd <= sign_xtnd_m(m_pres);
   
   pid_prev_sign_xtnd1 <= sign_xtnd_pid_prev(pid_prev1);
   pid_prev_sign_xtnd2 <= sign_xtnd_pid_prev(pid_prev2);
      
   fsfb_ctrl_dat0_o <=
      pid_prev_reg0(pid_prev_reg0'left) & pid_prev_reg0(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg0(DAC_DAT_WIDTH-1 downto 0);        
   fsfb_ctrl_dat1_o <=
      pid_prev_reg1(pid_prev_reg1'left) & pid_prev_reg1(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg1(DAC_DAT_WIDTH-1 downto 0);
   fsfb_ctrl_dat2_o <=
      pid_prev_reg2(pid_prev_reg2'left) & pid_prev_reg2(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg2(DAC_DAT_WIDTH-1 downto 0);
   fsfb_ctrl_dat3_o <=
      pid_prev_reg3(pid_prev_reg3'left) & pid_prev_reg3(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg3(DAC_DAT_WIDTH-1 downto 0);
   fsfb_ctrl_dat4_o <=
      pid_prev_reg4(pid_prev_reg4'left) & pid_prev_reg4(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg4(DAC_DAT_WIDTH-1 downto 0);
   fsfb_ctrl_dat5_o <=
      pid_prev_reg5(pid_prev_reg5'left) & pid_prev_reg5(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg5(DAC_DAT_WIDTH-1 downto 0);
   fsfb_ctrl_dat6_o <=
      pid_prev_reg6(pid_prev_reg6'left) & pid_prev_reg6(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg6(DAC_DAT_WIDTH-1 downto 0);
   fsfb_ctrl_dat7_o <=
      pid_prev_reg7(pid_prev_reg7'left) & pid_prev_reg7(DAC_DAT_WIDTH-2 downto 0) when flux_jumping_en_i = '0' else
      res_b_reg7(DAC_DAT_WIDTH-1 downto 0);
   
   fsfb_ctrl_dat_rdy_o <= pid_corr_rdy;

   m_pres0 <=
      m_prev_reg0 - 1 when (signed(res_a_reg0(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg0 /= M_MIN) and (flux_quanta_reg0 /= ZERO_QUANTA) else
      m_prev_reg0 + 1 when (signed(res_a_reg0(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg0 /= M_MAX) and (flux_quanta_reg0 /= ZERO_QUANTA) else
      m_prev_reg0;

   m_pres1 <=
      m_prev_reg1 - 1 when (signed(res_a_reg1(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg1 /= M_MIN) and (flux_quanta_reg1 /= ZERO_QUANTA) else 
      m_prev_reg1 + 1 when (signed(res_a_reg1(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg1 /= M_MAX) and (flux_quanta_reg1 /= ZERO_QUANTA) else 
      m_prev_reg1;

   m_pres2 <=
      m_prev_reg2 - 1 when (signed(res_a_reg2(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg2 /= M_MIN) and (flux_quanta_reg2 /= ZERO_QUANTA) else 
      m_prev_reg2 + 1 when (signed(res_a_reg2(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg2 /= M_MAX) and (flux_quanta_reg2 /= ZERO_QUANTA) else 
      m_prev_reg2;

   m_pres3 <=
      m_prev_reg3 - 1 when (signed(res_a_reg3(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg3 /= M_MIN) and (flux_quanta_reg3 /= ZERO_QUANTA) else 
      m_prev_reg3 + 1 when (signed(res_a_reg3(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg3 /= M_MAX) and (flux_quanta_reg3 /= ZERO_QUANTA) else 
      m_prev_reg3;

   m_pres4 <=
      m_prev_reg4 - 1 when (signed(res_a_reg4(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg4 /= M_MIN) and (flux_quanta_reg4 /= ZERO_QUANTA) else 
      m_prev_reg4 + 1 when (signed(res_a_reg4(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg4 /= M_MAX) and (flux_quanta_reg4 /= ZERO_QUANTA) else 
      m_prev_reg4;

   m_pres5 <=
      m_prev_reg5 - 1 when (signed(res_a_reg5(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg5 /= M_MIN) and (flux_quanta_reg5 /= ZERO_QUANTA) else 
      m_prev_reg5 + 1 when (signed(res_a_reg5(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg5 /= M_MAX) and (flux_quanta_reg5 /= ZERO_QUANTA) else 
      m_prev_reg5;

   m_pres6 <=
      m_prev_reg6 - 1 when (signed(res_a_reg6(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg6 /= M_MIN) and (flux_quanta_reg6 /= ZERO_QUANTA) else 
      m_prev_reg6 + 1 when (signed(res_a_reg6(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg6 /= M_MAX) and (flux_quanta_reg6 /= ZERO_QUANTA) else 
      m_prev_reg6;

   m_pres7 <=
      m_prev_reg7 - 1 when (signed(res_a_reg7(31 downto 0)) < signed(FSFB_MIN)) and (m_prev_reg7 /= M_MIN) and (flux_quanta_reg7 /= ZERO_QUANTA) else 
      m_prev_reg7 + 1 when (signed(res_a_reg7(31 downto 0)) > signed(FSFB_MAX)) and (m_prev_reg7 /= M_MAX) and (flux_quanta_reg7 /= ZERO_QUANTA) else 
      m_prev_reg7;
      
end rtl;