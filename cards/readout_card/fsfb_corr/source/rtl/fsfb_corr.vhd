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
-- $Id: fsfb_corr.vhd,v 1.1.2.1 2005/04/20 00:18:43 bburger Exp $
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
-- Revision 1.1.2.1  2005/04/20 00:18:43  bburger
-- Bryce:  new
--
--   
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;
use work.fsfb_corr_pack.all;

entity fsfb_corr is        
   port
   (
      -- fsfb_calc interface
      fsfb_ctrl_lock_en_i        : in std_logic;
      
      flux_quanta0_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta1_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta2_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta3_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta4_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta5_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta6_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta7_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      
      num_flux_quanta_prev0_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev1_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev2_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev3_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev4_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev5_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev6_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev7_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      
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

constant DATA_PATH0 : std_logic := '0';
constant DATA_PATH1 : std_logic := '1';

-- Control signals
signal start_corr            : std_logic;
signal rdy_clr               : std_logic;
signal column_switch         : std_logic_vector(2 downto 0);
signal result_switch         : std_logic;
signal pid_corr_rdy          : std_logic;
signal m_pres_rdy            : std_logic;

-- Data-path signals
signal flux_quanta           : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);

signal m_prev                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_pres                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_mltcnd              : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_mltcnd_sign_xtnd    : std_logic_vector(MULT_WIDTH-1 downto 0);
signal pid_prev_sign_xtnd    : std_logic_vector(SUB_WIDTH-1 downto 0);

signal pid_prev              : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
signal mult_res              : std_logic_vector(PROD_WIDTH-1 downto 0);
signal sub_res               : std_logic_vector(SUB_WIDTH-1 downto 0);

-- Registers for inputs
signal flux_quanta0          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta1          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta2          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta3          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta4          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta5          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta6          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta7          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z

signal m_prev0               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal m_prev1               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal m_prev2               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal m_prev3               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal m_prev4               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal m_prev5               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal m_prev6               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal m_prev7               : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev

signal pid_prev0             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
signal pid_prev1             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
signal pid_prev2             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
signal pid_prev3             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
signal pid_prev4             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
signal pid_prev5             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
signal pid_prev6             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
signal pid_prev7             : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev

signal fsfb_ctrl_dat_rdy0    : std_logic;
signal fsfb_ctrl_dat_rdy1    : std_logic;
signal fsfb_ctrl_dat_rdy2    : std_logic;
signal fsfb_ctrl_dat_rdy3    : std_logic;
signal fsfb_ctrl_dat_rdy4    : std_logic;
signal fsfb_ctrl_dat_rdy5    : std_logic;
signal fsfb_ctrl_dat_rdy6    : std_logic;
signal fsfb_ctrl_dat_rdy7    : std_logic;

-- Registers for corrected fsfb output
signal pid_corr_prev0        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev1        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev2        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev3        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev4        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev5        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev6        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev7        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);

signal pid_corr_prev_en0     : std_logic;
signal pid_corr_prev_en1     : std_logic;
signal pid_corr_prev_en2     : std_logic;
signal pid_corr_prev_en3     : std_logic;
signal pid_corr_prev_en4     : std_logic;
signal pid_corr_prev_en5     : std_logic;
signal pid_corr_prev_en6     : std_logic;
signal pid_corr_prev_en7     : std_logic;

-- Registers for arithmetic outputs
signal res_a0                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_a1                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_a2                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_a3                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_a4                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_a5                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_a6                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_a7                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 

signal res_a_en0             : std_logic; 
signal res_a_en1             : std_logic; 
signal res_a_en2             : std_logic; 
signal res_a_en3             : std_logic; 
signal res_a_en4             : std_logic; 
signal res_a_en5             : std_logic; 
signal res_a_en6             : std_logic; 
signal res_a_en7             : std_logic; 

signal res_b0                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_b1                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_b2                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_b3                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_b4                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_b5                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_b6                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
signal res_b7                : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 

signal res_b_en0             : std_logic; 
signal res_b_en1             : std_logic; 
signal res_b_en2             : std_logic; 
signal res_b_en3             : std_logic; 
signal res_b_en4             : std_logic; 
signal res_b_en5             : std_logic; 
signal res_b_en6             : std_logic; 
signal res_b_en7             : std_logic; 

signal m_new0                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new1                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new2                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new3                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new4                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new5                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new6                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
signal m_new7                : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);

signal m_new_en0             : std_logic;
signal m_new_en1             : std_logic;
signal m_new_en2             : std_logic;
signal m_new_en3             : std_logic;
signal m_new_en4             : std_logic;
signal m_new_en5             : std_logic;
signal m_new_en6             : std_logic;
signal m_new_en7             : std_logic;

type states is 
(
   IDLE, 
   CALCA0, CALCA1, CALCA2, CALCA3, CALCA4, CALCA5, CALCA6, CALCA7, 
   CALCB0, CALCB1, CALCB2, CALCB3, CALCB4, CALCB5, CALCB6, CALCB7, 
   CLEANUP
);                
signal present_state : states;
signal next_state    : states;

begin

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
            next_state <= CALCB0;
         when CALCB0 =>
            next_state <= CALCB1;
         when CALCB1 =>
            next_state <= CALCB2;
         when CALCB2 =>
            next_state <= CALCB3;
         when CALCB3 =>
            next_state <= CALCB4;
         when CALCB4 =>
            next_state <= CALCB5;
         when CALCB5 =>
            next_state <= CALCB6;
         when CALCB6 =>
            next_state <= CALCB7;
         when CALCB7 =>
            next_state <= CLEANUP;
         when CLEANUP =>
            next_state <= IDLE;
         when others =>
            next_state <= IDLE;
      end case;
   end process;

   state_out: process(present_state)
   begin   
      --defaults
      rdy_clr           <= '0';
      column_switch     <= COL0;
      result_switch     <= '0';
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

      pid_corr_prev_en0 <= '0';
      pid_corr_prev_en1 <= '0';
      pid_corr_prev_en2 <= '0';
      pid_corr_prev_en3 <= '0';
      pid_corr_prev_en4 <= '0';
      pid_corr_prev_en5 <= '0';
      pid_corr_prev_en6 <= '0';
      pid_corr_prev_en7 <= '0';
                    
      m_new_en0         <= '0'; 
      m_new_en1         <= '0'; 
      m_new_en2         <= '0'; 
      m_new_en3         <= '0'; 
      m_new_en4         <= '0'; 
      m_new_en5         <= '0'; 
      m_new_en6         <= '0'; 
      m_new_en7         <= '0'; 

      -- Data latency through the pipeline is four cycles:
      -- 1. Operand asserted at multiplier
      -- 2. Multiplier result registered
      -- 3. Result addition, comparison, m_pres registered
      -- 4. m_pres_rdy asserted
      
      case present_state is
         when IDLE =>
            column_switch <= COL0;
            result_switch <= DATA_PATH0;
         when CALCA0 =>
            rdy_clr       <= '1';
            column_switch <= COL1;
            result_switch <= DATA_PATH0;
         when CALCA1 =>
            column_switch <= COL2;
            result_switch <= DATA_PATH0;
         when CALCA2 =>
            column_switch <= COL3;
            result_switch <= DATA_PATH0;
         when CALCA3 =>
            column_switch <= COL4;
            result_switch <= DATA_PATH0;
         when CALCA4 =>
            column_switch <= COL5;
            result_switch <= DATA_PATH0;
         when CALCA5 =>
            column_switch <= COL6;
            result_switch <= DATA_PATH0;
         when CALCA6 =>
            column_switch <= COL7;
            result_switch <= DATA_PATH0;
         when CALCA7 =>
            column_switch <= COL0;
            result_switch <= DATA_PATH1;
         when CALCB0 =>
            column_switch <= COL1;
            result_switch <= DATA_PATH1;
         when CALCB1 =>
            column_switch <= COL2;
            result_switch <= DATA_PATH1;
         when CALCB2 =>
            column_switch <= COL3;
            result_switch <= DATA_PATH1;
         when CALCB3 =>
            column_switch <= COL4;
            result_switch <= DATA_PATH1;
         when CALCB4 =>
            column_switch <= COL5;
            result_switch <= DATA_PATH1;
         when CALCB5 =>
            column_switch <= COL6;
            result_switch <= DATA_PATH1;
         when CALCB6 =>
            column_switch <= COL7;
            result_switch <= DATA_PATH1;
         when CALCB7 =>
         when CLEANUP =>
            pid_corr_rdy  <= '1';
         when others =>
      end case;
   end process;

   -------------------------------
   -- Instantiations
   -------------------------------
   mult : fsfb_corr_multiplier
      port map (
         dataa  => flux_quanta,
         datab  => m_mltcnd_sign_xtnd,
         result => mult_res
      );
      
   sub1 : fsfb_corr_subtractor
      port map (
         dataa  => pid_prev_sign_xtnd,
         datab  => mult_res(SUB_WIDTH-1 downto 0),
         result => sub_res
      );

   -------------------------------
   -- Registered aritmetic outputs
   -------------------------------
   register_result: process(clk_i, rst_i)
   begin
      
      if(rst_i = '1') then
         
         res_a0 <= (others => '0'); 
         res_a1 <= (others => '0'); 
         res_a2 <= (others => '0'); 
         res_a3 <= (others => '0'); 
         res_a4 <= (others => '0'); 
         res_a5 <= (others => '0'); 
         res_a6 <= (others => '0'); 
         res_a7 <= (others => '0'); 

         res_b0 <= (others => '0'); 
         res_b1 <= (others => '0'); 
         res_b2 <= (others => '0'); 
         res_b3 <= (others => '0'); 
         res_b4 <= (others => '0'); 
         res_b5 <= (others => '0'); 
         res_b6 <= (others => '0'); 
         res_b7 <= (others => '0');
      
         m_new0 <= (others => '0');   
         m_new1 <= (others => '0');    
         m_new2 <= (others => '0');    
         m_new3 <= (others => '0');    
         m_new4 <= (others => '0');    
         m_new5 <= (others => '0');    
         m_new6 <= (others => '0');    
         m_new7 <= (others => '0');    

      elsif(clk_i'event and clk_i = '1') then
         
         if(res_a_en0 = '1') then
            res_a0 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_a_en1 = '1') then
            res_a1 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_a_en2 = '1') then
            res_a2 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_a_en3 = '1') then
            res_a3 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_a_en4 = '1') then
            res_a4 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_a_en5 = '1') then
            res_a5 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_a_en6 = '1') then
            res_a6 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_a_en7 = '1') then
            res_a7 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;

         if(res_b_en0 = '1') then
            res_b0 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_b_en1 = '1') then
            res_b1 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_b_en2 = '1') then
            res_b2 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_b_en3 = '1') then
            res_b3 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_b_en4 = '1') then
            res_b4 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_b_en5 = '1') then
            res_b5 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_b_en6 = '1') then
            res_b6 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         if(res_b_en7 = '1') then
            res_b7 <= sub_res(DAC_DAT_WIDTH-1 downto 0); 
         end if;
         
         if(m_new_en0 = '1') then
            m_new0 <= m_new; 
         end if;
         if(m_new_en1 = '1') then
            m_new1 <= m_new; 
         end if;
         if(m_new_en2 = '1') then
            m_new2 <= m_new; 
         end if;
         if(m_new_en3 = '1') then
            m_new3 <= m_new; 
         end if;
         if(m_new_en4 = '1') then
            m_new4 <= m_new; 
         end if;
         if(m_new_en5 = '1') then
            m_new5 <= m_new; 
         end if;
         if(m_new_en6 = '1') then
            m_new6 <= m_new; 
         end if;
         if(m_new_en7 = '1') then
            m_new7 <= m_new; 
         end if;
         
      end if;
   end process;

   -------------------------------
   -- Registered inputs
   -------------------------------
   register_inputs: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
      
         flux_quanta0          <= (others => '0');
         m_prev0               <= (others => '0');
         pid_prev0             <= (others => '0');
         fsfb_ctrl_dat_rdy0    <= '0';
         
         flux_quanta1          <= (others => '0');
         m_prev1               <= (others => '0');
         pid_prev1             <= (others => '0');
         fsfb_ctrl_dat_rdy1    <= '0';

         flux_quanta2          <= (others => '0');
         m_prev2               <= (others => '0');
         pid_prev2             <= (others => '0');
         fsfb_ctrl_dat_rdy2    <= '0';

         flux_quanta3          <= (others => '0');
         m_prev3               <= (others => '0');
         pid_prev3             <= (others => '0');
         fsfb_ctrl_dat_rdy3    <= '0';

         flux_quanta4          <= (others => '0');
         m_prev4               <= (others => '0');
         pid_prev4             <= (others => '0');
         fsfb_ctrl_dat_rdy4    <= '0';

         flux_quanta5          <= (others => '0');
         m_prev5               <= (others => '0');
         pid_prev5             <= (others => '0');
         fsfb_ctrl_dat_rdy5    <= '0';

         flux_quanta6          <= (others => '0');
         m_prev6               <= (others => '0');
         pid_prev6             <= (others => '0');
         fsfb_ctrl_dat_rdy6    <= '0';

         flux_quanta7          <= (others => '0');
         m_prev7               <= (others => '0');
         pid_prev7             <= (others => '0');
         fsfb_ctrl_dat_rdy7    <= '0';
      
      elsif(clk_i'event and clk_i = '1') then

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy0    <= '0';
         elsif(fsfb_ctrl_dat_rdy0_i = '1') then
            flux_quanta0          <= flux_quanta0_i;
            m_prev0               <= num_flux_quanta_prev0_i;
            pid_prev0             <= fsfb_ctrl_dat0_i;
            fsfb_ctrl_dat_rdy0    <= fsfb_ctrl_dat_rdy0_i;
         end if;
         
         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy1    <= '0';
         elsif(fsfb_ctrl_dat_rdy1_i = '1') then
            flux_quanta1          <= flux_quanta1_i;
            m_prev1               <= num_flux_quanta_prev1_i;
            pid_prev1             <= fsfb_ctrl_dat1_i;
            fsfb_ctrl_dat_rdy1    <= fsfb_ctrl_dat_rdy1_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy2    <= '0';
         elsif(fsfb_ctrl_dat_rdy2_i = '1') then
            flux_quanta2          <= flux_quanta2_i;
            m_prev2               <= num_flux_quanta_prev2_i;
            pid_prev2             <= fsfb_ctrl_dat2_i;
            fsfb_ctrl_dat_rdy2    <= fsfb_ctrl_dat_rdy2_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy3    <= '0';
         elsif(fsfb_ctrl_dat_rdy3_i = '1') then
            flux_quanta3          <= flux_quanta3_i;
            m_prev3               <= num_flux_quanta_prev3_i;
            pid_prev3             <= fsfb_ctrl_dat3_i;
            fsfb_ctrl_dat_rdy3    <= fsfb_ctrl_dat_rdy3_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy4    <= '0';
         elsif(fsfb_ctrl_dat_rdy4_i = '1') then
            flux_quanta4          <= flux_quanta4_i;
            m_prev4               <= num_flux_quanta_prev4_i;
            pid_prev4             <= fsfb_ctrl_dat4_i;
            fsfb_ctrl_dat_rdy4    <= fsfb_ctrl_dat_rdy4_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy5    <= '0';
         elsif(fsfb_ctrl_dat_rdy5_i = '1') then
            flux_quanta5          <= flux_quanta5_i;
            m_prev5               <= num_flux_quanta_prev5_i;
            pid_prev5             <= fsfb_ctrl_dat5_i;
            fsfb_ctrl_dat_rdy5    <= fsfb_ctrl_dat_rdy5_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy6    <= '0';
         elsif(fsfb_ctrl_dat_rdy6_i = '1') then
            flux_quanta6          <= flux_quanta6_i;
            m_prev6               <= num_flux_quanta_prev6_i;
            pid_prev6             <= fsfb_ctrl_dat6_i;
            fsfb_ctrl_dat_rdy6    <= fsfb_ctrl_dat_rdy6_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy7    <= '0';
         elsif(fsfb_ctrl_dat_rdy7_i = '1') then
            flux_quanta7          <= flux_quanta7_i;
            m_prev7               <= num_flux_quanta_prev7_i;
            pid_prev7             <= fsfb_ctrl_dat7_i;
            fsfb_ctrl_dat_rdy7    <= fsfb_ctrl_dat_rdy7_i;
         end if;
         
      end if;
   end process;

   -------------------------------
   --  Combinatorial Logic (MUXes, etc)
   -------------------------------
   flux_quanta <=
      flux_quanta0 when column_switch = COL0 else
      flux_quanta1 when column_switch = COL1 else
      flux_quanta2 when column_switch = COL2 else
      flux_quanta3 when column_switch = COL3 else
      flux_quanta4 when column_switch = COL4 else
      flux_quanta5 when column_switch = COL5 else
      flux_quanta6 when column_switch = COL6 else
      flux_quanta7 when column_switch = COL7;
   
   m_prev <=
      m_prev0 when column_switch = COL0 else
      m_prev1 when column_switch = COL1 else
      m_prev2 when column_switch = COL2 else
      m_prev3 when column_switch = COL3 else
      m_prev4 when column_switch = COL4 else
      m_prev5 when column_switch = COL5 else
      m_prev6 when column_switch = COL6 else
      m_prev7 when column_switch = COL7;
      
   pid_prev <=
      pid_prev0 when column_switch = COL0 else
      pid_prev1 when column_switch = COL1 else
      pid_prev2 when column_switch = COL2 else
      pid_prev3 when column_switch = COL3 else
      pid_prev4 when column_switch = COL4 else
      pid_prev5 when column_switch = COL5 else
      pid_prev6 when column_switch = COL6 else
      pid_prev7 when column_switch = COL7;
      
   num_flux_quanta_pres0_o <= m_new0;
   num_flux_quanta_pres1_o <= m_new1;
   num_flux_quanta_pres2_o <= m_new2;
   num_flux_quanta_pres3_o <= m_new3;
   num_flux_quanta_pres4_o <= m_new4;
   num_flux_quanta_pres5_o <= m_new5;
   num_flux_quanta_pres6_o <= m_new6;
   num_flux_quanta_pres7_o <= m_new7;
   num_flux_quanta_pres_rdy_o <= pid_corr_rdy;
   
   m_pres <=
      m_new0 when column_switch = COL0 else
      m_new1 when column_switch = COL1 else
      m_new2 when column_switch = COL2 else
      m_new3 when column_switch = COL3 else
      m_new4 when column_switch = COL4 else
      m_new5 when column_switch = COL5 else
      m_new6 when column_switch = COL6 else
      m_new7 when column_switch = COL7;
      
   start_corr <= 
      fsfb_ctrl_dat_rdy0 and
      fsfb_ctrl_dat_rdy1 and
      fsfb_ctrl_dat_rdy2 and
      fsfb_ctrl_dat_rdy3 and
      fsfb_ctrl_dat_rdy4 and
      fsfb_ctrl_dat_rdy5 and
      fsfb_ctrl_dat_rdy6 and
      fsfb_ctrl_dat_rdy7;
      
   m_mltcnd <=
      m_prev when result_switch = DATA_PATH0 else
      m_pres when result_switch = DATA_PATH1;
   
   m_mltcnd_sign_xtnd <= sign_xtnd_m(m_mltcnd);
   pid_prev_sign_xtnd <= sign_xtnd_pid_prev(pid_prev);
      
   fsfb_ctrl_dat0_o <=
      pid_prev0(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev0;        
   fsfb_ctrl_dat0_o <=
      pid_prev1(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev1;
   fsfb_ctrl_dat0_o <=
      pid_prev2(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev2;
   fsfb_ctrl_dat0_o <=
      pid_prev3(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev3;
   fsfb_ctrl_dat0_o <=
      pid_prev4(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev4;
   fsfb_ctrl_dat0_o <=
      pid_prev5(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev5;
   fsfb_ctrl_dat0_o <=
      pid_prev6(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev6;
   fsfb_ctrl_dat0_o <=
      pid_prev7(DAC_DAT_WIDTH-1 downto 0) when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev7;

   m_new <=
      m_prev + 1 when sub_res < FSFB_MIN else
      m_prev - 1 when sub_res > FSFB_MAX else
      m_prev;

end rtl;