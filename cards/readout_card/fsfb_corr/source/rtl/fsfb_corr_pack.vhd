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
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.data_types_pack.all;

library work;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;


package fsfb_corr_pack is

   constant FSFB_MAX : integer := (3/4)*(2**13);
   constant FSFB_MIN : integer := -(3/4)*(2**13);

component fsfb_corr is        
   port
   (
      -- fsfb_calc interface
      fsfb_ctrl_lock_en_i       : in std_logic;
      
      flux_quanta0_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      flux_quanta1_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      flux_quanta2_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      flux_quanta3_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      flux_quanta4_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      flux_quanta5_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      flux_quanta6_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      flux_quanta7_i            : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH);
      
      num_flux_quanta_prev0_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_prev1_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_prev2_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_prev3_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_prev4_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_prev5_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_prev6_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_prev7_i   : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      
      fsfb_ctrl_dat0_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      fsfb_ctrl_dat1_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      fsfb_ctrl_dat2_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      fsfb_ctrl_dat3_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      fsfb_ctrl_dat4_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      fsfb_ctrl_dat5_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      fsfb_ctrl_dat6_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      fsfb_ctrl_dat7_i          : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
      
      fsfb_ctrl_dat_rdy0_i      : in std_logic;
      fsfb_ctrl_dat_rdy1_i      : in std_logic;
      fsfb_ctrl_dat_rdy2_i      : in std_logic;
      fsfb_ctrl_dat_rdy3_i      : in std_logic;
      fsfb_ctrl_dat_rdy4_i      : in std_logic;
      fsfb_ctrl_dat_rdy5_i      : in std_logic;
      fsfb_ctrl_dat_rdy6_i      : in std_logic;
      fsfb_ctrl_dat_rdy7_i      : in std_logic;
      
      num_flux_quanta_pres0_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_pres1_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_pres2_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_pres3_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_pres4_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_pres5_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_pres6_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      num_flux_quanta_pres7_o   : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      
      num_flux_quanta_pres_rdy  : out std_logic;
      
      -- fsfb_ctrl interface
      fsfb_ctrl_dat0_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat1_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat2_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat3_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat4_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat5_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat6_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat7_o          : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat_rdy_o       : out  std_logic;
      
      -- Global Signals      
      clk_i                     : in std_logic;
      rst_i                     : in std_logic     
   );     
end component;


end fsfb_corr_pack;