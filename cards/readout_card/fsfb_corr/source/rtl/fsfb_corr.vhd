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
-- $Id$
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
--
--
-- Revision history:
-- $Log$
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

entity fsfb_corr is        
   port
   (
      -- fsfb_calc interface
      fsfb_ctrl_lock_en_i       : in std_logic;
      
      flux_quanta0_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta1_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta2_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta3_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta4_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta5_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta6_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      flux_quanta7_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
      
      num_flux_quanta_prev0_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev1_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev2_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev3_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev4_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev5_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev6_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      num_flux_quanta_prev7_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
      
      fsfb_ctrl_dat0_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat1_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat2_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat3_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat4_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat5_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat6_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      fsfb_ctrl_dat7_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
      
      fsfb_ctrl_dat_rdy0_i      : in std_logic;
      fsfb_ctrl_dat_rdy1_i      : in std_logic;
      fsfb_ctrl_dat_rdy2_i      : in std_logic;
      fsfb_ctrl_dat_rdy3_i      : in std_logic;
      fsfb_ctrl_dat_rdy4_i      : in std_logic;
      fsfb_ctrl_dat_rdy5_i      : in std_logic;
      fsfb_ctrl_dat_rdy6_i      : in std_logic;
      fsfb_ctrl_dat_rdy7_i      : in std_logic;
      
      num_flux_quanta_pres0_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres1_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres2_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres3_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres4_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres5_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres6_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      num_flux_quanta_pres7_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
      
      num_flux_quanta_pres_rdy  : out std_logic;
      
      -- fsfb_ctrl interface
      fsfb_ctrl_dat0_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat1_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat2_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat3_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat4_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat5_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat6_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat7_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
      fsfb_ctrl_dat_rdy_o       : out  std_logic;
      
      -- Global Signals      
      clk_i                     : in std_logic;
      rst_i                     : in std_logic     
   );     
end fsfb_corr;

architecture rtl of ac_dac_ctrl is

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
signal pid_prev              : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
signal op2                   : std_logic_vector(31 downto 0);
signal mult_res              : std_logic_vector(64 downto 0);

-- Registers
signal flux_quanta0          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta1          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta2          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta3          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta4          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta5          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta6          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
signal flux_quanta7          : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z

signal num_flux_quanta_prev0 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal num_flux_quanta_prev1 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal num_flux_quanta_prev2 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal num_flux_quanta_prev3 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal num_flux_quanta_prev4 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal num_flux_quanta_prev5 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal num_flux_quanta_prev6 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev
signal num_flux_quanta_prev7 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_prev

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

signal pid_corr_prev0        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev1        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev2        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev3        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev4        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev5        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev6        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
signal pid_corr_prev7        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);

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
   
   state_NS: process(start_corr)
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
            next_insert_state <= IDLE;
      end case;
   end process;

   state_out: process()
   begin   
      --defaults
      rdy_clr       <= '0';
      column_switch <= COL0;
      result_switch <= '0';
      pid_corr_rdy  <= '0';
      m_pres_rdy    <= '0';      

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
         datab  => op2,
         result => mult_res
      );

   -------------------------------
   -- Registered inputs
   -------------------------------
   register_inputs: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
      
         flux_quanta0          <= (others => '0');
         num_flux_quanta_prev0 <= (others => '0');
         pid_prev0             <= (others => '0');
         fsfb_ctrl_dat_rdy0    <= '0';
         
         flux_quanta1          <= (others => '0');
         num_flux_quanta_prev1 <= (others => '0');
         pid_prev1             <= (others => '0');
         fsfb_ctrl_dat_rdy1    <= '0';

         flux_quanta2          <= (others => '0');
         num_flux_quanta_prev2 <= (others => '0');
         pid_prev2             <= (others => '0');
         fsfb_ctrl_dat_rdy2    <= '0';

         flux_quanta3          <= (others => '0');
         num_flux_quanta_prev3 <= (others => '0');
         pid_prev3             <= (others => '0');
         fsfb_ctrl_dat_rdy3    <= '0';

         flux_quanta4          <= (others => '0');
         num_flux_quanta_prev4 <= (others => '0');
         pid_prev4             <= (others => '0');
         fsfb_ctrl_dat_rdy4    <= '0';

         flux_quanta5          <= (others => '0');
         num_flux_quanta_prev5 <= (others => '0');
         pid_prev5             <= (others => '0');
         fsfb_ctrl_dat_rdy5    <= '0';

         flux_quanta6          <= (others => '0');
         num_flux_quanta_prev6 <= (others => '0');
         pid_prev6             <= (others => '0');
         fsfb_ctrl_dat_rdy6    <= '0';

         flux_quanta7          <= (others => '0');
         num_flux_quanta_prev7 <= (others => '0');
         pid_prev7             <= (others => '0');
         fsfb_ctrl_dat_rdy7    <= '0';
      
      elsif(clk_i'event and clk_i = '1') then

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy0    <= '0';
         elsif(fsfb_ctrl_dat_rdy0_i = '1') then
            flux_quanta0          <= flux_quanta0_i;
            num_flux_quanta_prev0 <= num_flux_quanta_prev0_i;
            pid_prev0             <= fsfb_ctrl_dat0_i;
            fsfb_ctrl_dat_rdy0    <= fsfb_ctrl_dat_rdy0_i;
         end if;
         
         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy1    <= '0';
         elsif(fsfb_ctrl_dat_rdy1_i = '1') then
            flux_quanta1          <= flux_quanta1_i;
            num_flux_quanta_prev1 <= num_flux_quanta_prev1_i;
            pid_prev1             <= fsfb_ctrl_dat1_i;
            fsfb_ctrl_dat_rdy1    <= fsfb_ctrl_dat_rdy1_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy2    <= '0';
         elsif(fsfb_ctrl_dat_rdy2_i = '1') then
            flux_quanta2          <= flux_quanta2_i;
            num_flux_quanta_prev2 <= num_flux_quanta_prev2_i;
            pid_prev2             <= fsfb_ctrl_dat2_i;
            fsfb_ctrl_dat_rdy2    <= fsfb_ctrl_dat_rdy2_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy3    <= '0';
         elsif(fsfb_ctrl_dat_rdy3_i = '1') then
            flux_quanta3          <= flux_quanta3_i;
            num_flux_quanta_prev3 <= num_flux_quanta_prev3_i;
            pid_prev3             <= fsfb_ctrl_dat3_i;
            fsfb_ctrl_dat_rdy3    <= fsfb_ctrl_dat_rdy3_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy4    <= '0';
         elsif(fsfb_ctrl_dat_rdy4_i = '1') then
            flux_quanta4          <= flux_quanta4_i;
            num_flux_quanta_prev4 <= num_flux_quanta_prev4_i;
            pid_prev4             <= fsfb_ctrl_dat4_i;
            fsfb_ctrl_dat_rdy4    <= fsfb_ctrl_dat_rdy4_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy5    <= '0';
         elsif(fsfb_ctrl_dat_rdy5_i = '1') then
            flux_quanta5          <= flux_quanta5_i;
            num_flux_quanta_prev5 <= num_flux_quanta_prev5_i;
            pid_prev5             <= fsfb_ctrl_dat5_i;
            fsfb_ctrl_dat_rdy5    <= fsfb_ctrl_dat_rdy5_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy6    <= '0';
         elsif(fsfb_ctrl_dat_rdy6_i = '1') then
            flux_quanta6          <= flux_quanta6_i;
            num_flux_quanta_prev6 <= num_flux_quanta_prev6_i;
            pid_prev6             <= fsfb_ctrl_dat6_i;
            fsfb_ctrl_dat_rdy6    <= fsfb_ctrl_dat_rdy6_i;
         end if;

         if(rdy_clr = '1') then
            fsfb_ctrl_dat_rdy7    <= '0';
         elsif(fsfb_ctrl_dat_rdy7_i = '1') then
            flux_quanta7          <= flux_quanta7_i;
            num_flux_quanta_prev7 <= num_flux_quanta_prev7_i;
            pid_prev7             <= fsfb_ctrl_dat7_i;
            fsfb_ctrl_dat_rdy7    <= fsfb_ctrl_dat_rdy7_i;
         end if;
         
      end if;
   end process;

   -------------------------------
   --  Combinatorial Logic (MUXes, etc)
   -------------------------------
   flux_quanta <=
      flux_quanta_0 when column_switch = COL0 else
      flux_quanta_1 when column_switch = COL1 else
      flux_quanta_2 when column_switch = COL2 else
      flux_quanta_3 when column_switch = COL3 else
      flux_quanta_4 when column_switch = COL4 else
      flux_quanta_5 when column_switch = COL5 else
      flux_quanta_6 when column_switch = COL6 else
      flux_quanta_7 when column_switch = COL7;
   
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
      
   start_corr <= 
      fsfb_ctrl_dat_rdy0 and
      fsfb_ctrl_dat_rdy1 and
      fsfb_ctrl_dat_rdy2 and
      fsfb_ctrl_dat_rdy3 and
      fsfb_ctrl_dat_rdy4 and
      fsfb_ctrl_dat_rdy5 and
      fsfb_ctrl_dat_rdy6 and
      fsfb_ctrl_dat_rdy7;
      
   op2 <=
      m_prev when result_switch = DATA_PATH0 else
      m_pres when result_switch = DATA_PATH1;
      
   fsfb_ctrl_dat0_o <=
      pid_prev0 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev0;        
   fsfb_ctrl_dat0_o <=
      pid_prev1 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev1;
   fsfb_ctrl_dat0_o <=
      pid_prev2 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev2;
   fsfb_ctrl_dat0_o <=
      pid_prev3 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev3;
   fsfb_ctrl_dat0_o <=
      pid_prev4 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev4;
   fsfb_ctrl_dat0_o <=
      pid_prev5 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev5;
   fsfb_ctrl_dat0_o <=
      pid_prev6 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev6;
   fsfb_ctrl_dat0_o <=
      pid_prev7 when fsfb_ctrl_lock_en_i = '0' else
      pid_corr_prev7;

end rtl;