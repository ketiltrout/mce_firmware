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
-- $Id: fsfb_corr_pack.vhd,v 1.1.2.2 2005/04/21 00:27:18 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- $Log: fsfb_corr_pack.vhd,v $
-- Revision 1.1.2.2  2005/04/21 00:27:18  bburger
-- Bryce:  Code update.  All files compile now.
--
-- Revision 1.1.2.1  2005/04/20 00:18:43  bburger
-- Bryce:  new
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

--library sys_param;
--use sys_param.data_types_pack.all;

library work;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

package fsfb_corr_pack is

   constant SUB_WIDTH              : integer := 48;
   constant MULT_WIDTH             : integer := 32;
   constant PROD_WIDTH             : integer := 64;

   constant FSFB_MAX               : std_logic_vector(DAC_DAT_WIDTH-1 downto 0) := "01100000000000"; --(3/4)*(2**13);
   constant FSFB_MIN               : std_logic_vector(DAC_DAT_WIDTH-1 downto 0) := "10100000000000"; -- -(3/4)*(2**13);
   constant SIGN_XTND_M_POS        : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');
   constant SIGN_XTND_M_NEG        : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '1');
   constant SIGN_XTND_PID_PREV_POS : std_logic_vector(SUB_WIDTH-FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');
   constant SIGN_XTND_PID_PREV_NEG : std_logic_vector(SUB_WIDTH-FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '1');

   component fsfb_corr is        
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
   end component;

   component fsfb_corr_multiplier is
      port (
         dataa    : IN STD_LOGIC_VECTOR (MULT_WIDTH-1 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (MULT_WIDTH-1 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (PROD_WIDTH-1 DOWNTO 0)
      );   
   end component fsfb_corr_multiplier; 
   
   component fsfb_corr_subtractor is
      port (
         dataa    : IN STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0)
      );   
   end component fsfb_corr_subtractor; 

   function sign_xtnd_m (input : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0)) return std_logic_vector;

   function sign_xtnd_pid_prev (input : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0)) return std_logic_vector;
   
end fsfb_corr_pack;

package body fsfb_corr_pack is

   function sign_xtnd_m (input : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
   begin
      case input(FLUX_QUANTA_CNT_WIDTH-1) is
         when '0' =>    result := SIGN_XTND_M_POS & input;           
         when '1' =>    result := SIGN_XTND_M_NEG & input;
         when others => result := (others => '0');
      end case;
      return result;
   end function sign_xtnd_m;

   function sign_xtnd_pid_prev (input : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(SUB_WIDTH-1 downto 0);
   begin
      case input(FSFB_QUEUE_DATA_WIDTH-1) is
         when '0' =>    result := SIGN_XTND_PID_PREV_POS & input;           
         when '1' =>    result := SIGN_XTND_PID_PREV_NEG & input;
         when others => result := (others => '0');
      end case;
      return result;
   end function sign_xtnd_pid_prev;

end package body fsfb_corr_pack;