-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
-- 
--
-- $Id: tb_cc_rcs_bcs_ac.vhd,v 1.33 2006/10/02 18:58:53 bburger Exp $
--
-- Project:      Scuba 2
-- Author:       Bryce Burger
-- Organisation: UBC
--
-- Title
-- tb_cc_rcs_bcs_ac.vhd
--
-- Description:
--
-- Revision history:
-- $Log: tb_cc_rcs_bcs_ac.vhd,v $
-- Revision 1.33  2006/10/02 18:58:53  bburger
-- Bryce:  v01000012
--
-- Revision 1.32  2006/09/21 16:20:57  bburger
-- Bryce:  Added support for testing TES Bias Step internal commands
--
-- Revision 1.31  2006/09/15 00:51:02  bburger
-- Bryce:  new section added for testing maximum length commands
--
-- Revision 1.30  2006/09/07 22:31:12  bburger
-- Bryce:  more test cases for psuc testing
--
-- Revision 1.29  2006/09/06 19:57:34  bburger
-- Bryce:  PSUC communications simulation added
--
-- Revision 1.28  2006/08/21 19:43:57  bburger
-- Bryce:  PSUC testing
--
-- Revision 1.27  2006/08/18 22:59:18  bburger
-- Bryce:  v0200000f
--
-- Revision 1.26  2006/08/03 03:23:14  bburger
-- Bryce:  Trying to fix a bug associated with the error code.  The error code is delayed by one command.
--
-- Revision 1.25  2006/08/02 16:23:02  bburger
-- Bryce:  trying to fixed occasional wb bugs in issue_reply
--
-- Revision 1.23  2006/06/09 22:17:55  bburger
-- Bryce:  Modified to output the correct frame sequence number -- internal or manchester
--
-- Revision 1.22  2006/06/03 02:29:15  bburger
-- Bryce:  The size of data packets returned is now based on num_rows*NUM_CHANNELS
--
-- Revision 1.21  2006/05/30 00:53:37  bburger
-- Bryce:  Interim committal
--
-- Revision 1.20  2006/05/19 00:57:48  bburger
-- Bryce:  Committal for backup
--
-- Revision 1.19  2006/03/17 16:54:43  bburger
-- Bryce:  refined test routine for testing dv_rx
--
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.bc_dac_ctrl_pack.all;
use work.addr_card_pack.all;
use work.bias_card_pack.all;
use work.readout_card_pack.all;
use work.cc_reset_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

entity tb_cc_rcs_bcs_ac is     
end tb_cc_rcs_bcs_ac;

architecture tb of tb_cc_rcs_bcs_ac is 

   component clk_card
   port(
      -- PLL input:
      inclk14           : in std_logic;
      rst_n             : in std_logic;
      
      -- Manchester Clock PLL inputs:
      inclk15           : in std_logic;

      -- LVDS interface:
      lvds_cmd          : out std_logic;
      lvds_sync         : out std_logic;
      lvds_spare        : out std_logic;
      lvds_clk          : out std_logic;
      lvds_reply_ac_a   : in std_logic;  
      lvds_reply_ac_b   : in std_logic;
      lvds_reply_bc1_a  : in std_logic;
      lvds_reply_bc1_b  : in std_logic;
      lvds_reply_bc2_a  : in std_logic;
      lvds_reply_bc2_b  : in std_logic;
      lvds_reply_bc3_a  : in std_logic;
      lvds_reply_bc3_b  : in std_logic;
      lvds_reply_rc1_a  : in std_logic;
      lvds_reply_rc1_b  : in std_logic;
      lvds_reply_rc2_a  : in std_logic;
      lvds_reply_rc2_b  : in std_logic;
      lvds_reply_rc3_a  : in std_logic; 
      lvds_reply_rc3_b  : in std_logic;  
      lvds_reply_rc4_a  : in std_logic; 
      lvds_reply_rc4_b  : in std_logic;
      
      -- DV interface:
      dv_pulse_fibre    : in std_logic;
      manchester_data   : in std_logic;
      manchester_sigdet : in std_logic;
      
      -- TTL interface:
      ttl_nrx1          : in std_logic;
      ttl_tx1           : out std_logic;
      ttl_txena1        : out std_logic;
      
      ttl_nrx2          : in std_logic;
      ttl_tx2           : out std_logic;
      ttl_txena2        : out std_logic;

      ttl_nrx3          : in std_logic;
      ttl_tx3           : out std_logic;
      ttl_txena3        : out std_logic;

      -- eeprom interface:
      eeprom_si         : in std_logic;
      eeprom_so         : out std_logic;
      eeprom_sck        : out std_logic;
      eeprom_cs         : out std_logic;

--      psdo              : in std_logic;
--      pscso             : in std_logic;
--      psclko            : in std_logic;
--      psdi              : out std_logic;
--      pscsi             : out std_logic;
--      psclki            : out std_logic;

      mosii             : in std_logic;
      sclki             : in std_logic;
      ccssi             : in std_logic;
      misoo             : out std_logic;
      sreqo             : out std_logic;
      
      -- miscellaneous ports:
      red_led           : out std_logic;
      ylw_led           : out std_logic;
      grn_led           : out std_logic;
      dip_sw3           : in std_logic;
      dip_sw4           : in std_logic;
      wdog              : out std_logic;
      slot_id           : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      mictor0_o         : out std_logic_vector(15 downto 0);
      mictor0clk_o      : out std_logic;
      mictor0_e         : out std_logic_vector(15 downto 0);
      mictor0clk_e      : out std_logic;
      rx          : in std_logic;
      tx          : out std_logic;
      
      -- interface to HOTLINK fibre receiver      
      fibre_rx_refclk   : out std_logic;
      fibre_rx_data     : in std_logic_vector (7 downto 0);  
      fibre_rx_rdy      : in std_logic;                      
      fibre_rx_rvs      : in std_logic;                      
      fibre_rx_status   : in std_logic;                      
      fibre_rx_sc_nd    : in std_logic;                      
      fibre_rx_clkr     : in std_logic;     
      fibre_rx_a_nb     : out std_logic;
      fibre_rx_bisten   : out std_logic;
      fibre_rx_rf       : out std_logic;
      
      -- interface to hotlink fibre transmitter      
      fibre_tx_clkw     : out std_logic;
      fibre_tx_data     : out std_logic_vector (7 downto 0);
      fibre_tx_ena      : out std_logic;  
      fibre_tx_sc_nd    : out std_logic;

      nreconf           : out std_logic;
      nepc_sel          : out std_logic
   );     
   end component;

   component readout_card
      generic (
         CARD : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0)
      );
      port (
         rst_n          : in  std_logic;
         inclk          : in  std_logic;
         adc1_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc2_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc3_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc4_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc5_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc6_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc7_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc8_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc1_ovr       : in  std_logic;
         adc2_ovr       : in  std_logic;
         adc3_ovr       : in  std_logic;
         adc4_ovr       : in  std_logic;
         adc5_ovr       : in  std_logic;
         adc6_ovr       : in  std_logic;
         adc7_ovr       : in  std_logic;
         adc8_ovr       : in  std_logic;
         adc1_rdy       : in  std_logic;
         adc2_rdy       : in  std_logic;
         adc3_rdy       : in  std_logic;
         adc4_rdy       : in  std_logic;
         adc5_rdy       : in  std_logic;
         adc6_rdy       : in  std_logic;
         adc7_rdy       : in  std_logic;
         adc8_rdy       : in  std_logic;
         adc1_clk       : out std_logic;
         adc2_clk       : out std_logic;
         adc3_clk       : out std_logic;
         adc4_clk       : out std_logic;
         adc5_clk       : out std_logic;
         adc6_clk       : out std_logic;
         adc7_clk       : out std_logic;
         adc8_clk       : out std_logic;
         dac_FB1_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB2_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB3_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB4_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB5_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB6_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB7_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB8_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB_clk     : out std_logic_vector(7 downto 0);
         dac_clk        : out std_logic_vector(7 downto 0);
         dac_dat        : out std_logic_vector(7 downto 0);
         bias_dac_ncs   : out std_logic_vector(7 downto 0);
         offset_dac_ncs : out std_logic_vector(7 downto 0);
         lvds_cmd       : in  std_logic;
         lvds_sync      : in  std_logic;
         lvds_spare     : in  std_logic;
         lvds_txa       : out std_logic;
         lvds_txb       : out std_logic;

         -- TTL interface:
         ttl_dir1        : out std_logic;
         ttl_in1         : in std_logic;
         ttl_out1        : out std_logic;
         ttl_dir2        : out std_logic;
         ttl_in2         : in std_logic;
         ttl_out2        : out std_logic;
         ttl_dir3        : out std_logic;
         ttl_in3         : in std_logic;
         ttl_out3        : out std_logic;

         red_led        : out std_logic;
         ylw_led        : out std_logic;
         grn_led        : out std_logic;
         dip_sw3        : in  std_logic;
         dip_sw4        : in  std_logic;
         wdog           : out std_logic;
         slot_id        : in  std_logic_vector(3 downto 0);
         card_id        : inout  std_logic;
         mictor         : out std_logic_vector(31 downto 0)
      );
   end component;

   component bias_card
   port(
 
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      
      -- TTL interface:
      ttl_nrx1   : in std_logic;
      ttl_tx1    : out std_logic;
      ttl_txena1 : out std_logic;
      
      ttl_nrx2   : in std_logic;
      ttl_tx2    : out std_logic;
      ttl_txena2 : out std_logic;
      
      ttl_nrx3   : in std_logic;
      ttl_tx3    : out std_logic;
      ttl_txena3 : out std_logic;

      -- eeprom interface:
      eeprom_si  : in std_logic;
      eeprom_so  : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs  : out std_logic;
                  
      -- dac interface:
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      lvds_dac_ncs  : out std_logic;
      lvds_dac_sclk : out std_logic;
      lvds_dac_data : out std_logic;
      dac_nclr      : out std_logic; -- add to tcl file
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      card_id    : inout std_logic;
      smb_clk           : out std_logic;
      smb_data          : inout std_logic;      
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx   : in std_logic;
      tx   : out std_logic
   );
   end component;
 
   ------------------------------------------------
   -- Simulation Signals
   ------------------------------------------------
   signal clk          : std_logic := '0';
   signal mem_clk      : std_logic := '0';
   signal comm_clk     : std_logic := '0';      
   signal fibre_clk    : std_logic := '0';
   signal lvds_clk_i   : std_logic := '0';
   signal sync_en      : std_logic_vector(1 downto 0) := "00";

   constant clk_period          : TIME := 40 ns;    -- 50Mhz clock
   constant spi_clk_period      : TIME := 666 ns;
   constant fibre_clk_period    : TIME := 40 ns;
     
   constant pci_dsp_dly         : TIME := 160 ns;   -- delay between tranmission of 4byte packets from PCI 
   constant fibre_clkr_prd      : TIME := 40 ns;   -- 25MHz clock
   
   constant preamble1          : std_logic_vector(7 downto 0)  := X"A5";
   constant preamble2          : std_logic_vector(7 downto 0)  := X"5A";
   constant reset_char         : std_logic_vector(7 downto 0)  := X"0B";
   constant command_wb         : std_logic_vector(31 downto 0) := X"20205742";
   constant command_rb         : std_logic_vector(31 downto 0) := x"20205242";
   constant command_go         : std_logic_vector(31 downto 0) := X"2020474F";
   constant command_st         : std_logic_vector(31 downto 0) := x"20205354";
   constant command_rs         : std_logic_vector(31 downto 0) := x"20205253";
   signal address_id           : std_logic_vector(31 downto 0) := X"00000000";--X"0002015C";

   constant under_cover_ret_dat_cmd : std_logic_vector(31 downto 0) := x"00" & ALL_READOUT_CARDS & x"00" & RET_DAT_ADDR;

   constant rcs_ret_dat_cmd         : std_logic_vector(31 downto 0) := X"000B0016";  -- card id=4, ret_dat command
   constant rcs_data_mode_cmd       : std_logic_vector(31 downto 0) := x"00" & ALL_READOUT_CARDS & x"00" & DATA_MODE_ADDR;
   constant rcs_led_cmd             : std_logic_vector(31 downto 0) := x"00" & ALL_READOUT_CARDS & x"00" & LED_ADDR;
   
   constant rc1_ret_dat_cmd         : std_logic_vector(31 downto 0) := X"00030016";  -- card_addr=READOUT_CARD_1, param_id=RET_DAT_ADDR
   constant rc1_data_mode_cmd       : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & DATA_MODE_ADDR;
   constant rc1_row_len_cmd         : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & ROW_LEN_ADDR;    
   constant rc1_num_rows_cmd        : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & NUM_ROWS_ADDR;
   constant rc1_sample_dly_cmd      : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & SAMPLE_DLY_ADDR;
   constant rc1_sample_num_cmd      : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & SAMPLE_NUM_ADDR;
   constant rc1_fb_dly_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FB_DLY_ADDR;
   constant rc1_servo_mode_cmd      : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & SERVO_MODE_ADDR;
   constant rc1_sa_bias_cmd         : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & SA_BIAS_ADDR;
   constant rc1_offset_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & OFFSET_ADDR;
   constant rc1_gainp0_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP0_ADDR;
   constant rc1_gainp1_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP1_ADDR;
   constant rc1_flx_quanta0_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA0_ADDR;
   constant rc1_flx_quanta1_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA1_ADDR;
   constant rc1_flx_quanta2_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA2_ADDR;
   constant rc1_flx_quanta3_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA3_ADDR;
   constant rc1_flx_quanta4_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA4_ADDR;
   constant rc1_flx_quanta5_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA5_ADDR;
   constant rc1_flx_quanta6_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA6_ADDR;
   constant rc1_flx_quanta7_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_QUANTA7_ADDR;
   constant rc1_flx_lp_init_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLX_LP_INIT_ADDR;
   constant rc1_fltr_rst_cmd        : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FLTR_RST_ADDR;
   constant rc1_ramp_step_cmd       : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & RAMP_STEP_ADDR;
   constant rc1_ramp_amp_cmd        : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & RAMP_AMP_ADDR;
   constant rc1_ramp_dly_cmd        : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & RAMP_DLY_ADDR;
   constant rc1_fb_const_cmd        : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FB_CONST_ADDR;
   constant rc1_captr_raw_cmd       : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & CAPTR_RAW_ADDR;
   constant rc1_en_fb_jump_cmd      : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & EN_FB_JUMP_ADDR;
   constant rc1_adc_offset0_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & ADC_OFFSET0_ADDR;
   constant rc1_led_cmd             : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & LED_ADDR;
   
   constant rc2_led_cmd             : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_2    & x"00" & LED_ADDR;
   constant rc2_ret_dat_cmd         : std_logic_vector(31 downto 0) := X"00040016";  -- card_addr=READOUT_CARD_2, param_id=RET_DAT_ADDR
   
   constant rc3_led_cmd             : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_3    & x"00" & LED_ADDR;
   constant rc3_ret_dat_cmd         : std_logic_vector(31 downto 0) := X"00050016";  -- card_addr=READOUT_CARD_3, param_id=RET_DAT_ADDR
   
   constant rc4_led_cmd             : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & LED_ADDR;
   constant rc4_ret_dat_cmd         : std_logic_vector(31 downto 0) := X"00060016";  -- card_addr=READOUT_CARD_4, param_id=RET_DAT_ADDR
   constant rc4_data_mode_cmd       : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & DATA_MODE_ADDR;
   constant rc4_servo_mode_cmd      : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & SERVO_MODE_ADDR;
   constant rc4_fb_const            : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & FB_CONST_ADDR;
   constant rc4_row_len_cmd         : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & ROW_LEN_ADDR;    
   constant rc4_num_rows_cmd        : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & NUM_ROWS_ADDR;
   constant rc4_sample_delay_cmd    : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & SAMPLE_DLY_ADDR;
   constant rc4_sample_num_cmd      : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & SAMPLE_NUM_ADDR;
   constant rc4_fb_dly_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & FB_DLY_ADDR;
   constant rc4_flx_lp_init_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & FLX_LP_INIT_ADDR;
   constant rc4_row_dly_cmd         : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & ROW_DLY_ADDR;
   
   constant cc_fw_rev_cmd           : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & FW_REV_ADDR;    
   constant cc_config_fac_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CONFIG_FAC_ADDR;    
   constant cc_config_app_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CONFIG_APP_ADDR;    
   constant cc_row_len_cmd          : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & ROW_LEN_ADDR;    
   constant cc_num_rows_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & NUM_ROWS_ADDR;
   constant cc_ret_dat_s_cmd        : std_logic_vector(31 downto 0) := X"00020053";  -- card id=0, ret_dat_s command
   signal   ret_dat_s_stop          : std_logic_vector(31 downto 0) := X"0000000F";   
   constant cc_led_cmd              : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & LED_ADDR;
   constant cc_array_id_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & ARRAY_ID_ADDR;
   constant cc_use_dv_cmd           : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & USE_DV_ADDR;
   constant cc_use_sync_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & USE_SYNC_ADDR;
   constant cc_data_rate_cmd        : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & DATA_RATE_ADDR;
   constant cc_select_clk_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & SELECT_CLK_ADDR;

   constant cc_tes_tgl_en_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_EN_ADDR;
   constant cc_tes_tgl_max_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_MAX_ADDR;
   constant cc_tes_tgl_min_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_MIN_ADDR;
   constant cc_tes_tgl_rate_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_RATE_ADDR;
   constant cc_int_cmd_en_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & INT_CMD_EN_ADDR;

   constant psu_brst_mce_cmd        : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & BRST_MCE_ADDR;
   constant psu_cycle_pow_cmd       : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & CYCLE_POW_ADDR;
   constant psu_cut_pow_cmd         : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & CUT_POW_ADDR;
   constant psu_status_cmd          : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & PSC_STATUS_ADDR;

   constant bcs_flux_fdbck_cmd      : std_logic_vector(31 downto 0) := x"00" & ALL_BIAS_CARDS    & x"00" & FLUX_FB_ADDR;
   constant bcs_bias_cmd            : std_logic_vector(31 downto 0) := x"00" & ALL_BIAS_CARDS    & x"00" & BIAS_ADDR;
 
   constant ac_led_cmd              : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & LED_ADDR;
   constant ac_on_bias_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ON_BIAS_ADDR;
   constant ac_off_bias_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & OFF_BIAS_ADDR;
   constant ac_row_order_cmd        : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ROW_ORDER_ADDR;
   constant ac_enbl_mux_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ENBL_MUX_ADDR;
   constant ac_row_dly_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ROW_DLY_ADDR;
   constant ac_row_len_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ROW_LEN_ADDR;    
   constant ac_num_rows_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & NUM_ROWS_ADDR;
   
   constant bc1_flux_fb_cmd         : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1       & x"00" & FLUX_FB_ADDR;
   constant bc1_bias_cmd            : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1       & x"00" & BIAS_ADDR;

   constant bc2_led_cmd             : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_2       & x"00" & LED_ADDR;
   
   constant all_row_len_cmd         : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & ROW_LEN_ADDR;    
   constant all_num_rows_cmd        : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & NUM_ROWS_ADDR;
   constant all_sample_delay_cmd    : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & SAMPLE_DLY_ADDR; 
   constant all_sample_num_cmd      : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & SAMPLE_NUM_ADDR; 
   constant all_fb_dly_cmd          : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & FB_DLY_ADDR;     
   constant all_flx_lp_init_cmd     : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & FLX_LP_INIT_ADDR;
   constant all_row_dly_cmd         : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & ROW_DLY_ADDR;
                                                                                                     
   constant data_block              : positive := 58;                                                       
   
   signal checksum                  : std_logic_vector(31 downto 0) := X"00000000";
   signal command                   : std_logic_vector(31 downto 0);   
   signal data_valid                : std_logic_vector(31 downto 0); -- used to be set to constant X"00000028"
   signal data                      : std_logic_vector(31 downto 0) := X"00000001";--integer := 1;
      
   ------------------------------------------------
   -- Counter Signals
   ------------------------------------------------
   signal ctr_ena         : std_logic := '1';
   signal ctr_load        : std_logic := '0';
   signal ctr_count_i     : integer := 0;
   signal ctr_count_o     : integer;
   signal ctr_count_slv_o : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);

   ------------------------------------------------
   -- Counter Signals
   ------------------------------------------------
   -- For Bus Backplane Rev. A and B
   -- slot ID decode logic:
--   signal cc_slot_id  : std_logic_vector(3 downto 0) := "1000";
--   signal rc4_slot_id : std_logic_vector(3 downto 0) := "0111";
--   signal rc3_slot_id : std_logic_vector(3 downto 0) := "0110";
--   signal rc2_slot_id : std_logic_vector(3 downto 0) := "1010";
--   signal rc1_slot_id : std_logic_vector(3 downto 0) := "1011";
--   signal ac_slot_id  : std_logic_vector(3 downto 0) := "1111";
--   signal bc1_slot_id : std_logic_vector(3 downto 0) := "1110";
--   signal bc2_slot_id : std_logic_vector(3 downto 0) := "1101";
--   signal bc3_slot_id : std_logic_vector(3 downto 0) := "1100";

   -- For Bus Backplane Rev. C
   -- slot ID decode logic:
   signal ac_slot_id  : std_logic_vector(3 downto 0) := "0000";
   signal bc1_slot_id : std_logic_vector(3 downto 0) := "0001";
   signal bc2_slot_id : std_logic_vector(3 downto 0) := "0010";
   signal bc3_slot_id : std_logic_vector(3 downto 0) := "0011";
   signal rc1_slot_id : std_logic_vector(3 downto 0) := "0100";
   signal rc2_slot_id : std_logic_vector(3 downto 0) := "0101";
   signal rc3_slot_id : std_logic_vector(3 downto 0) := "0110";
   signal rc4_slot_id : std_logic_vector(3 downto 0) := "0111";
   signal cc_slot_id  : std_logic_vector(3 downto 0) := "1000";

   ------------------------------------------------
   -- Clock Card Signals
   -------------------------------------------------
   -- PLL input:
   signal inclk      : std_logic := '0';
   signal inclk15    : std_logic := '1';
   signal rst_n      : std_logic := '1';
   signal rst        : std_logic := '0';
   signal inclk_en   : std_logic := '1';
   signal inclk_conditioned : std_logic := '0';
   signal switch_to_xtal    : std_logic := '0';
   signal switch_to_manch   : std_logic := '0';
--   signal spi_clk    : std_logic := '0';
--   signal spi_data   : std_logic := '0';
   signal spi_clk_cond : std_logic := '0';
   signal spi_clk_en : std_logic := '0';
   
   -- LVDS interface:
   signal lvds_cmd   : std_logic;
   signal lvds_sync  : std_logic;
   signal cc_lvds_sync  : std_logic;
   signal noisy_sync : std_logic;
   signal lvds_spare : std_logic;
   signal lvds_clk   : std_logic;
   signal lvds_reply_ac_a : std_logic := '1';  
   signal lvds_reply_ac_b : std_logic := '1';
   signal lvds_reply_bc1_a : std_logic := '1';
   signal lvds_reply_bc1_b : std_logic := '1';
   signal lvds_reply_bc2_a : std_logic := '1';
   signal lvds_reply_bc2_b : std_logic := '1';
   signal lvds_reply_bc3_a : std_logic := '1';
   signal lvds_reply_bc3_b : std_logic := '1';
   signal rc1_lvds_txa : std_logic := '1';
   signal rc1_lvds_txb : std_logic := '1';
   signal rc2_lvds_txa : std_logic := '1';
   signal rc2_lvds_txb : std_logic := '1';
   signal rc3_lvds_txa : std_logic := '1'; 
   signal rc3_lvds_txb : std_logic := '1';  
   signal rc4_lvds_txa : std_logic := '1'; 
   signal rc4_lvds_txb : std_logic := '1';
   
   -- DV interface:
   signal dv_pulse_fibre  : std_logic := '1';
   -- manchester_data is active low
   signal manchester_data : std_logic := '1';
   -- manchester_sigdet is active high
   signal manchester_sigdet : std_logic := '1';

   
   -- TTL interface:
   signal cc_ttl_txena1 : std_logic := '0';
   signal cc_ttl_txena2 : std_logic := '1';
   signal cc_ttl_txena3 : std_logic := '1';
   signal cc_ttl_nrx2   : std_logic := '0';
   signal cc_ttl_nrx3   : std_logic := '0';
   
   -- eeprom interface:
   signal cc_eeprom_si  : std_logic := '0';
   signal cc_eeprom_so  : std_logic;
   signal cc_eeprom_sck : std_logic;
   signal cc_eeprom_cs  : std_logic;

--   signal cc_psdo       : std_logic;
--   signal cc_pscso      : std_logic := '1';
--   signal cc_psclko     : std_logic;
--   signal cc_psdi       : std_logic := '0';
--   signal cc_pscsi      : std_logic := '1';
--   signal cc_psclki     : std_logic := '0';

   signal cc_mosii      : std_logic := '0';
   signal cc_sclki      : std_logic := '0';
   signal cc_ccssi      : std_logic := '0';
   signal cc_misoo      : std_logic;
   signal cc_sreqo      : std_logic;
   
   signal cc_n5vok      : std_logic := '0';
                     
   -- miscellaneous ports:
   signal cc_red_led    : std_logic;
   signal cc_ylw_led    : std_logic;
   signal cc_grn_led    : std_logic;
   signal cc_dip_sw3    : std_logic := '1';
   signal cc_dip_sw4    : std_logic := '1';
   signal cc_wdog       : std_logic;
   
   -- debug ports:
   signal cc_mictor_o    : std_logic_vector(15 downto 0);
   signal cc_mictorclk_o : std_logic;
   signal cc_mictor_e    : std_logic_vector(15 downto 0);
   signal cc_mictorclk_e : std_logic;
   signal cc_rs232_rx    : std_logic := '0';
   signal cc_rs232_tx    : std_logic;
   
   -- interface to HOTLINK fibre receiver      
   signal fibre_rx_data      : std_logic_vector (7 downto 0);  
   signal fibre_rx_rdy       : std_logic;                      
   signal fibre_rx_rvs       : std_logic;                      
   signal fibre_rx_status    : std_logic;                      
   signal fibre_rx_sc_nd     : std_logic;                      
   signal fibre_rx_ckr       : std_logic := '0';                      
   
   -- interface to hotlink fibre transmitter      
   signal fibre_tx_data      : std_logic_vector (7 downto 0);
   signal fibre_tx_ena       : std_logic;  
   signal fibre_tx_sc_nd     : std_logic;

   signal nreconf            : std_logic;
   signal nepc_sel           : std_logic;


   ------------------------------------------------
   -- Readout Card 4 Signals
   -------------------------------------------------
   signal rc4_adc1_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc2_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc3_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc4_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc5_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc6_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc7_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc8_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc4_adc1_ovr       : std_logic := '0';
   signal rc4_adc2_ovr       : std_logic := '0';
   signal rc4_adc3_ovr       : std_logic := '0';
   signal rc4_adc4_ovr       : std_logic := '0';
   signal rc4_adc5_ovr       : std_logic := '0';
   signal rc4_adc6_ovr       : std_logic := '0';
   signal rc4_adc7_ovr       : std_logic := '0';
   signal rc4_adc8_ovr       : std_logic := '0';
   signal rc4_adc1_rdy       : std_logic;
   signal rc4_adc2_rdy       : std_logic;
   signal rc4_adc3_rdy       : std_logic;
   signal rc4_adc4_rdy       : std_logic;
   signal rc4_adc5_rdy       : std_logic;
   signal rc4_adc6_rdy       : std_logic;
   signal rc4_adc7_rdy       : std_logic;
   signal rc4_adc8_rdy       : std_logic;
   signal rc4_adc1_clk       : std_logic;
   signal rc4_adc2_clk       : std_logic;
   signal rc4_adc3_clk       : std_logic;
   signal rc4_adc4_clk       : std_logic;
   signal rc4_adc5_clk       : std_logic;
   signal rc4_adc6_clk       : std_logic;
   signal rc4_adc7_clk       : std_logic;
   signal rc4_adc8_clk       : std_logic;
   signal rc4_dac_FB1_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB2_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB3_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB4_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB5_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB6_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB7_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB8_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc4_dac_FB_clk     : std_logic_vector(7 downto 0);
   signal rc4_dac_clk        : std_logic_vector(7 downto 0);
   signal rc4_dac_dat        : std_logic_vector(7 downto 0);
   signal rc4_bias_dac_ncs   : std_logic_vector(7 downto 0);
   signal rc4_offset_dac_ncs : std_logic_vector(7 downto 0);

   signal rc4_ttl_dir1       : std_logic := '1';
   signal rc4_ttl_dir2       : std_logic := '1';
   signal rc4_ttl_in2        : std_logic := '0';
   signal rc4_ttl_dir3       : std_logic := '1';
   signal rc4_ttl_in3        : std_logic := '0';

   signal rc4_red_led        : std_logic;
   signal rc4_ylw_led        : std_logic;
   signal rc4_grn_led        : std_logic;

   signal rc4_dip_sw3        : std_logic;
   signal rc4_dip_sw4        : std_logic;
   signal rc4_wdog           : std_logic;
   signal rc4_card_id        : std_logic;
   signal rc4_mictor         : std_logic_vector(31 downto 0);


   ------------------------------------------------
   -- Readout Card 3 Signals
   -------------------------------------------------
   signal rc3_adc1_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc2_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc3_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc4_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc5_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc6_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc7_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc8_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc3_adc1_ovr       : std_logic := '0';
   signal rc3_adc2_ovr       : std_logic := '0';
   signal rc3_adc3_ovr       : std_logic := '0';
   signal rc3_adc4_ovr       : std_logic := '0';
   signal rc3_adc5_ovr       : std_logic := '0';
   signal rc3_adc6_ovr       : std_logic := '0';
   signal rc3_adc7_ovr       : std_logic := '0';
   signal rc3_adc8_ovr       : std_logic := '0';
   signal rc3_adc1_rdy       : std_logic;
   signal rc3_adc2_rdy       : std_logic;
   signal rc3_adc3_rdy       : std_logic;
   signal rc3_adc4_rdy       : std_logic;
   signal rc3_adc5_rdy       : std_logic;
   signal rc3_adc6_rdy       : std_logic;
   signal rc3_adc7_rdy       : std_logic;
   signal rc3_adc8_rdy       : std_logic;
   signal rc3_adc1_clk       : std_logic;
   signal rc3_adc2_clk       : std_logic;
   signal rc3_adc3_clk       : std_logic;
   signal rc3_adc4_clk       : std_logic;
   signal rc3_adc5_clk       : std_logic;
   signal rc3_adc6_clk       : std_logic;
   signal rc3_adc7_clk       : std_logic;
   signal rc3_adc8_clk       : std_logic;
   signal rc3_dac_FB1_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB2_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB3_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB4_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB5_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB6_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB7_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB8_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc3_dac_FB_clk     : std_logic_vector(7 downto 0);
   signal rc3_dac_clk        : std_logic_vector(7 downto 0);
   signal rc3_dac_dat        : std_logic_vector(7 downto 0);
   signal rc3_bias_dac_ncs   : std_logic_vector(7 downto 0);
   signal rc3_offset_dac_ncs : std_logic_vector(7 downto 0);

   signal rc3_ttl_dir1       : std_logic := '1';
   signal rc3_ttl_dir2       : std_logic := '1';
   signal rc3_ttl_in2        : std_logic := '0';
   signal rc3_ttl_dir3       : std_logic := '1';
   signal rc3_ttl_in3        : std_logic := '0';

   signal rc3_red_led        : std_logic;
   signal rc3_ylw_led        : std_logic;
   signal rc3_grn_led        : std_logic;

   signal rc3_dip_sw3        : std_logic;
   signal rc3_dip_sw4        : std_logic;
   signal rc3_wdog           : std_logic;
   signal rc3_card_id        : std_logic;
   signal rc3_mictor         : std_logic_vector(31 downto 0);


   ------------------------------------------------
   -- Readout Card 2 Signals
   -------------------------------------------------
   signal rc2_adc1_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc2_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc3_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc4_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc5_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc6_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc7_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc8_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   signal rc2_adc1_ovr       : std_logic := '0';
   signal rc2_adc2_ovr       : std_logic := '0';
   signal rc2_adc3_ovr       : std_logic := '0';
   signal rc2_adc4_ovr       : std_logic := '0';
   signal rc2_adc5_ovr       : std_logic := '0';
   signal rc2_adc6_ovr       : std_logic := '0';
   signal rc2_adc7_ovr       : std_logic := '0';
   signal rc2_adc8_ovr       : std_logic := '0';
   signal rc2_adc1_rdy       : std_logic;
   signal rc2_adc2_rdy       : std_logic;
   signal rc2_adc3_rdy       : std_logic;
   signal rc2_adc4_rdy       : std_logic;
   signal rc2_adc5_rdy       : std_logic;
   signal rc2_adc6_rdy       : std_logic;
   signal rc2_adc7_rdy       : std_logic;
   signal rc2_adc8_rdy       : std_logic;
   signal rc2_adc1_clk       : std_logic;
   signal rc2_adc2_clk       : std_logic;
   signal rc2_adc3_clk       : std_logic;
   signal rc2_adc4_clk       : std_logic;
   signal rc2_adc5_clk       : std_logic;
   signal rc2_adc6_clk       : std_logic;
   signal rc2_adc7_clk       : std_logic;
   signal rc2_adc8_clk       : std_logic;
   signal rc2_dac_FB1_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB2_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB3_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB4_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB5_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB6_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB7_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB8_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc2_dac_FB_clk     : std_logic_vector(7 downto 0);
   signal rc2_dac_clk        : std_logic_vector(7 downto 0);
   signal rc2_dac_dat        : std_logic_vector(7 downto 0);
   signal rc2_bias_dac_ncs   : std_logic_vector(7 downto 0);
   signal rc2_offset_dac_ncs : std_logic_vector(7 downto 0);

   signal rc2_ttl_dir1       : std_logic := '1';
   signal rc2_ttl_dir2       : std_logic := '1';
   signal rc2_ttl_in2        : std_logic := '0';
   signal rc2_ttl_dir3       : std_logic := '1';
   signal rc2_ttl_in3        : std_logic := '0';

   signal rc2_red_led        : std_logic;
   signal rc2_ylw_led        : std_logic;
   signal rc2_grn_led        : std_logic;

   signal rc2_dip_sw3        : std_logic;
   signal rc2_dip_sw4        : std_logic;
   signal rc2_wdog           : std_logic;
   signal rc2_card_id        : std_logic;
   signal rc2_mictor         : std_logic_vector(31 downto 0);


   ------------------------------------------------
   -- Readout Card 1 Signals
   -------------------------------------------------
   signal rc1_adc1_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc2_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc3_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc4_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc5_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc6_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc7_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc8_dat       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0) := (others => '0');
   signal rc1_adc1_ovr       : std_logic := '0';
   signal rc1_adc2_ovr       : std_logic := '0';
   signal rc1_adc3_ovr       : std_logic := '0';
   signal rc1_adc4_ovr       : std_logic := '0';
   signal rc1_adc5_ovr       : std_logic := '0';
   signal rc1_adc6_ovr       : std_logic := '0';
   signal rc1_adc7_ovr       : std_logic := '0';
   signal rc1_adc8_ovr       : std_logic := '0';
   signal rc1_adc1_rdy       : std_logic;
   signal rc1_adc2_rdy       : std_logic;
   signal rc1_adc3_rdy       : std_logic;
   signal rc1_adc4_rdy       : std_logic;
   signal rc1_adc5_rdy       : std_logic;
   signal rc1_adc6_rdy       : std_logic;
   signal rc1_adc7_rdy       : std_logic;
   signal rc1_adc8_rdy       : std_logic;
   signal rc1_adc1_clk       : std_logic;
   signal rc1_adc2_clk       : std_logic;
   signal rc1_adc3_clk       : std_logic;
   signal rc1_adc4_clk       : std_logic;
   signal rc1_adc5_clk       : std_logic;
   signal rc1_adc6_clk       : std_logic;
   signal rc1_adc7_clk       : std_logic;
   signal rc1_adc8_clk       : std_logic;
   signal rc1_dac_FB1_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB2_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB3_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB4_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB5_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB6_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB7_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB8_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   signal rc1_dac_FB_clk     : std_logic_vector(7 downto 0);
   signal rc1_dac_clk        : std_logic_vector(7 downto 0);
   signal rc1_dac_dat        : std_logic_vector(7 downto 0);
   signal rc1_bias_dac_ncs   : std_logic_vector(7 downto 0);
   signal rc1_offset_dac_ncs : std_logic_vector(7 downto 0);

   signal rc1_ttl_dir1       : std_logic := '1';
   signal rc1_ttl_dir2       : std_logic := '1';
   signal rc1_ttl_in2        : std_logic := '0';
   signal rc1_ttl_dir3       : std_logic := '1';
   signal rc1_ttl_in3        : std_logic := '0';

   signal rc1_red_led        : std_logic;
   signal rc1_ylw_led        : std_logic;
   signal rc1_grn_led        : std_logic;

   signal rc1_dip_sw3        : std_logic := '1';
   signal rc1_dip_sw4        : std_logic := '1';
   signal rc1_wdog           : std_logic;
   signal rc1_card_id        : std_logic;
   signal rc1_mictor         : std_logic_vector(31 downto 0);


   ------------------------------------------------
   -- Address Card Signals
   -------------------------------------------------
   -- TTL interface:
   signal bclr          : std_logic;
   signal bclr_n        : std_logic;
   signal ac_ttl_txena1 : std_logic := '1';
   signal ac_ttl_txena2 : std_logic := '1';
   signal ac_ttl_txena3 : std_logic := '1';
   signal ac_ttl_nrx2   : std_logic := '0';
   signal ac_ttl_nrx3   : std_logic := '0';
    
   -- eeprom interface:
   signal ac_eeprom_si  : std_logic;
   signal ac_eeprom_so  : std_logic;
   signal ac_eeprom_sck : std_logic;
   signal ac_eeprom_cs  : std_logic;
    
   -- dac interface:
   signal ac_dac_data0  : std_logic_vector(13 downto 0);
   signal ac_dac_data1  : std_logic_vector(13 downto 0);
   signal ac_dac_data2  : std_logic_vector(13 downto 0);
   signal ac_dac_data3  : std_logic_vector(13 downto 0);
   signal ac_dac_data4  : std_logic_vector(13 downto 0);
   signal ac_dac_data5  : std_logic_vector(13 downto 0);
   signal ac_dac_data6  : std_logic_vector(13 downto 0);
   signal ac_dac_data7  : std_logic_vector(13 downto 0);
   signal ac_dac_data8  : std_logic_vector(13 downto 0);
   signal ac_dac_data9  : std_logic_vector(13 downto 0);
   signal ac_dac_data10 : std_logic_vector(13 downto 0);
   signal ac_dac_clk    : std_logic_vector(40 downto 0);
    
   -- miscellaneous ports:
   signal ac_red_led    : std_logic;
   signal ac_ylw_led    : std_logic;
   signal ac_grn_led    : std_logic;
   signal ac_dip_sw3    : std_logic := '1';
   signal ac_dip_sw4    : std_logic := '1';
   signal ac_wdog       : std_logic;
    
   -- debug ports:
   signal ac_test       : std_logic_vector(16 downto 3);
   signal ac_mictor     : std_logic_vector(32 downto 1);
   signal ac_mictorclk  : std_logic_vector(2 downto 1);
   signal ac_rs232_rx   : std_logic;
   signal ac_rs232_tx   : std_logic;   
   
   
   ------------------------------------------------
   -- Bias Card 1 Signals
   -------------------------------------------------
   -- TTL interface:
   signal bc1_ttl_txena1    : std_logic := '1';
   signal bc1_ttl_txena2    : std_logic := '1';
   signal bc1_ttl_txena3    : std_logic := '1';
   signal bc1_ttl_nrx2      : std_logic := '0';
   signal bc1_ttl_nrx3      : std_logic := '0';
   
   -- eeprom ice:nterface:
   signal bc1_eeprom_si     : std_logic;
   signal bc1_eeprom_so     : std_logic;
   signal bc1_eeprom_sck    : std_logic;
   signal bc1_eeprom_cs     : std_logic;
   
   -- dac interface:
   signal bc1_dac_ncs       : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal bc1_dac_sclk      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal bc1_dac_data      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);   
   signal bc1_lvds_dac_ncs  : std_logic;
   signal bc1_lvds_dac_sclk : std_logic;
   signal bc1_lvds_dac_data : std_logic;
   signal bc1_dac_nclr      : std_logic; -- add to tcl file
   
   -- miscellaneous ports:
   signal bc1_red_led       : std_logic;
   signal bc1_ylw_led       : std_logic;
   signal bc1_grn_led       : std_logic;
   signal bc1_dip_sw3       : std_logic;
   signal bc1_dip_sw4       : std_logic;
   signal bc1_wdog          : std_logic;
   
   -- debug ports:
   signal bc1_test          : std_logic_vector(16 downto 3);
   signal bc1_mictor        : std_logic_vector(32 downto 1);
   signal bc1_mictorclk     : std_logic_vector(2 downto 1);
   signal bc1_rs232_rx      : std_logic;
   signal bc1_rs232_tx      : std_logic;   


   ------------------------------------------------
   -- Bias Card 2 Signals
   -------------------------------------------------
   -- TTL interface:
   signal bc2_ttl_txena1    : std_logic := '1';
   signal bc2_ttl_txena2    : std_logic := '1';
   signal bc2_ttl_txena3    : std_logic := '1';
   signal bc2_ttl_nrx2      : std_logic := '0';
   signal bc2_ttl_nrx3      : std_logic := '0';
   
   -- eeprom ice:nterface:
   signal bc2_eeprom_si     : std_logic;
   signal bc2_eeprom_so     : std_logic;
   signal bc2_eeprom_sck    : std_logic;
   signal bc2_eeprom_cs     : std_logic;
   
   -- dac interface:
   signal bc2_dac_ncs       : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal bc2_dac_sclk      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal bc2_dac_data      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);   
   signal bc2_lvds_dac_ncs  : std_logic;
   signal bc2_lvds_dac_sclk : std_logic;
   signal bc2_lvds_dac_data : std_logic;
   signal bc2_dac_nclr      : std_logic; -- add to tcl file
   
   -- miscellaneous ports:
   signal bc2_red_led       : std_logic;
   signal bc2_ylw_led       : std_logic;
   signal bc2_grn_led       : std_logic;
   signal bc2_dip_sw3       : std_logic;
   signal bc2_dip_sw4       : std_logic;
   signal bc2_wdog          : std_logic;
   
   -- debug ports:
   signal bc2_test          : std_logic_vector(16 downto 3);
   signal bc2_mictor        : std_logic_vector(32 downto 1);
   signal bc2_mictorclk     : std_logic_vector(2 downto 1);
   signal bc2_rs232_rx      : std_logic;
   signal bc2_rs232_tx      : std_logic;   


   ------------------------------------------------
   -- Bias Card 3 Signals
   -------------------------------------------------
   -- TTL interface:
   signal bc3_ttl_txena1    : std_logic := '1';
   signal bc3_ttl_txena2    : std_logic := '1';
   signal bc3_ttl_txena3    : std_logic := '1';
   signal bc3_ttl_nrx2      : std_logic := '0';
   signal bc3_ttl_nrx3      : std_logic := '0';
   
   -- eeprom ice:nterface:
   signal bc3_eeprom_si     : std_logic;
   signal bc3_eeprom_so     : std_logic;
   signal bc3_eeprom_sck    : std_logic;
   signal bc3_eeprom_cs     : std_logic;
   
   -- dac interface:
   signal bc3_dac_ncs       : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal bc3_dac_sclk      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal bc3_dac_data      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);   
   signal bc3_lvds_dac_ncs  : std_logic;
   signal bc3_lvds_dac_sclk : std_logic;
   signal bc3_lvds_dac_data : std_logic;
   signal bc3_dac_nclr      : std_logic; -- add to tcl file
   
   -- miscellaneous ports:
   signal bc3_red_led       : std_logic;
   signal bc3_ylw_led       : std_logic;
   signal bc3_grn_led       : std_logic;
   signal bc3_dip_sw3       : std_logic;
   signal bc3_dip_sw4       : std_logic;
   signal bc3_wdog          : std_logic;
   
   -- debug ports:
   signal bc3_test          : std_logic_vector(16 downto 3);
   signal bc3_mictor        : std_logic_vector(32 downto 1);
   signal bc3_mictorclk     : std_logic_vector(2 downto 1);
   signal bc3_rs232_rx      : std_logic;
   signal bc3_rs232_tx      : std_logic;   

begin
   bclr_n <= not bclr;
   lvds_sync <= 
      cc_lvds_sync when sync_en = "00" else 
      '0'          when sync_en = "01" else
      noisy_sync   when sync_en = "10";
   
   ------------------------------------------------
   -- Create test bench clock
   -------------------------------------------------
   
   i_counter : counter
--   generic map(
--      MAX         : integer := 255;
--      STEP_SIZE   : integer := 1;
--      WRAP_AROUND : std_logic := '1';
--      UP_COUNTER  : std_logic := '1'
--   );
   port map(
      clk_i   => inclk,
      rst_i   => rst_n,
      ena_i   => ctr_ena,
      load_i  => ctr_load,
      count_i => ctr_count_i,
      count_o => ctr_count_o
   );
   
   rst          <= rst_n;
   
   -- Clock generation
   inclk        <= not inclk        after clk_period/2;
   inclk15      <= not inclk15      after clk_period/2;
   fibre_rx_ckr <= not fibre_rx_ckr after fibre_clk_period/2;
   
   -- Used for simulating the loss of the crystal clock
   inclk_conditioned <= inclk_en and inclk;
   
   ctr_count_slv_o <= std_logic_vector(conv_unsigned(ctr_count_o, DAC_DAT_WIDTH));
   rc1_adc1_rdy <= inclk;
   rc1_adc2_rdy <= inclk;
   rc1_adc3_rdy <= inclk;
   rc1_adc4_rdy <= inclk;
   rc1_adc5_rdy <= inclk;
   rc1_adc6_rdy <= inclk;
   rc1_adc7_rdy <= inclk;
   rc1_adc8_rdy <= inclk;
   rc1_adc1_dat <= "01001110001000";  --5000
   rc1_adc2_dat <= "01001110001000";  --ctr_count_slv_o;
   rc1_adc3_dat <= "11111111110000";  --ctr_count_slv_o;
   rc1_adc4_dat <= "11111111110000";  --ctr_count_slv_o;
   rc1_adc5_dat <= "11111111110000";  --ctr_count_slv_o;
   rc1_adc6_dat <= "11111111110000";  --ctr_count_slv_o;
   rc1_adc7_dat <= "11111111110000";  --ctr_count_slv_o;
   rc1_adc8_dat <= "11111111110000";  --ctr_count_slv_o;
   rc2_adc1_rdy <= inclk;
   rc2_adc2_rdy <= inclk;
   rc2_adc3_rdy <= inclk;
   rc2_adc4_rdy <= inclk;
   rc2_adc5_rdy <= inclk;
   rc2_adc6_rdy <= inclk;
   rc2_adc7_rdy <= inclk;
   rc2_adc8_rdy <= inclk;
   rc2_adc1_dat <= ctr_count_slv_o;
   rc2_adc2_dat <= ctr_count_slv_o;
   rc2_adc3_dat <= ctr_count_slv_o;
   rc2_adc4_dat <= ctr_count_slv_o;
   rc2_adc5_dat <= ctr_count_slv_o;
   rc2_adc6_dat <= ctr_count_slv_o;
   rc2_adc7_dat <= ctr_count_slv_o;
   rc2_adc8_dat <= ctr_count_slv_o;
   rc3_adc1_rdy <= inclk;
   rc3_adc2_rdy <= inclk;
   rc3_adc3_rdy <= inclk;
   rc3_adc4_rdy <= inclk;
   rc3_adc5_rdy <= inclk;
   rc3_adc6_rdy <= inclk;
   rc3_adc7_rdy <= inclk;
   rc3_adc8_rdy <= inclk;
   rc3_adc1_dat <= ctr_count_slv_o;
   rc3_adc2_dat <= ctr_count_slv_o;
   rc3_adc3_dat <= ctr_count_slv_o;
   rc3_adc4_dat <= ctr_count_slv_o;
   rc3_adc5_dat <= ctr_count_slv_o;
   rc3_adc6_dat <= ctr_count_slv_o;
   rc3_adc7_dat <= ctr_count_slv_o;
   rc3_adc8_dat <= ctr_count_slv_o;
   rc3_adc1_rdy <= inclk;
   rc4_adc2_rdy <= inclk;
   rc4_adc3_rdy <= inclk;
   rc4_adc4_rdy <= inclk;
   rc4_adc5_rdy <= inclk;
   rc4_adc6_rdy <= inclk;
   rc4_adc7_rdy <= inclk;
   rc4_adc8_rdy <= inclk;
   rc4_adc1_dat <= ctr_count_slv_o;
   rc4_adc2_dat <= ctr_count_slv_o;
   rc4_adc3_dat <= ctr_count_slv_o;
   rc4_adc4_dat <= ctr_count_slv_o;
   rc4_adc5_dat <= ctr_count_slv_o;
   rc4_adc6_dat <= ctr_count_slv_o;
   rc4_adc7_dat <= ctr_count_slv_o;
   rc4_adc8_dat <= ctr_count_slv_o;

   i_clk_card : clk_card
      port map
      (
         -- PLL input:
         inclk14          => inclk_conditioned,
         rst_n            => rst_n,

         -- Manchester Clock PLL inputs:
         inclk15          => inclk15,
                          
         -- LVDS interface:
         lvds_cmd         => lvds_cmd,  
         lvds_sync        => cc_lvds_sync, 
         lvds_spare       => lvds_spare,
         lvds_clk         => lvds_clk,  
         lvds_reply_ac_a  => lvds_reply_ac_a, 
         lvds_reply_ac_b  => lvds_reply_ac_b, 
         lvds_reply_bc1_a => lvds_reply_bc1_a,
         lvds_reply_bc1_b => lvds_reply_bc1_b,
         lvds_reply_bc2_a => lvds_reply_bc2_a,
         lvds_reply_bc2_b => lvds_reply_bc2_b,
         lvds_reply_bc3_a => lvds_reply_bc3_a,
         lvds_reply_bc3_b => lvds_reply_bc3_b,
         lvds_reply_rc1_a => rc1_lvds_txa,
         lvds_reply_rc1_b => rc1_lvds_txb,
         lvds_reply_rc2_a => rc2_lvds_txa,
         lvds_reply_rc2_b => rc2_lvds_txb,
         lvds_reply_rc3_a => rc3_lvds_txa,
         lvds_reply_rc3_b => rc3_lvds_txb,
         lvds_reply_rc4_a => rc4_lvds_txa,
         lvds_reply_rc4_b => rc4_lvds_txb,
                          
         -- DV interface:
         dv_pulse_fibre   => dv_pulse_fibre,
         manchester_data  => manchester_data,  
         manchester_sigdet => manchester_sigdet,
      
         -- TTL interface:
         ttl_nrx1         => bclr_n,
         ttl_tx1          => bclr,
         ttl_txena1       => cc_ttl_txena1,
         
         ttl_nrx2         => cc_ttl_nrx2,
         ttl_tx2          => open,
         ttl_txena2       => cc_ttl_txena2,

         ttl_nrx3         => cc_ttl_nrx3,
         ttl_tx3          => open,
         ttl_txena3       => cc_ttl_txena3,
                          
         -- eeprom interface:
         eeprom_si        => cc_eeprom_si,
         eeprom_so        => cc_eeprom_so, 
         eeprom_sck       => cc_eeprom_sck,
         eeprom_cs        => cc_eeprom_cs, 

--         psdo             => cc_psdo,   
--         pscso            => cc_pscso,  
--         psclko           => cc_psclko, 
--         
--         -- I'm putting a clock input on the data line to see what we get
--         psdi             => spi_data,--cc_psdi,  
--         pscsi            => cc_pscsi, 
--         psclki           => spi_clk,--cc_psclki,
----         n5vok            => cc_n5vok, 
         mosii            => cc_mosii,
         sclki            => cc_sclki, 
         ccssi            => cc_ccssi,
         misoo            => cc_misoo,
         sreqo            => cc_sreqo,
                             
         -- miscellaneous ports:
         red_led          => cc_red_led,
         ylw_led          => cc_ylw_led,
         grn_led          => cc_grn_led,
         dip_sw3          => cc_dip_sw3,
         dip_sw4          => cc_dip_sw4,
         wdog             => cc_wdog,  
         slot_id          => cc_slot_id,
                          
         -- debug ports:  
         mictor0_o        => cc_mictor_o,   
         mictor0clk_o     => cc_mictorclk_o,
         mictor0_e        => cc_mictor_e,   
         mictor0clk_e     => cc_mictorclk_e,
         rx               => cc_rs232_rx,
         tx               => cc_rs232_tx,
         
         -- interface to HOTLINK fibre receiver         
         fibre_rx_refclk  => open,
         fibre_rx_data    => fibre_rx_data,   
         fibre_rx_rdy     => fibre_rx_rdy,    
         fibre_rx_rvs     => fibre_rx_rvs,    
         fibre_rx_status  => fibre_rx_status, 
         fibre_rx_sc_nd   => fibre_rx_sc_nd,  
         fibre_rx_clkr    => fibre_rx_ckr,    
         
         -- interface to hotlink fibre transmitter         
         fibre_tx_clkw    => open,
         fibre_tx_data    => fibre_tx_data,   
         fibre_tx_ena     => fibre_tx_ena,    
         fibre_tx_sc_nd   => fibre_tx_sc_nd,

         nreconf          => nreconf,
         nepc_sel         => nepc_sel
      );

--   i_readout_card4: readout_card
--      generic map (
--         CARD => READOUT_CARD_4
--      )
--      port map (
--         rst_n          => rst_n,
--         inclk          => lvds_clk,
--         adc1_dat       => rc4_adc1_dat,
--         adc2_dat       => rc4_adc2_dat,
--         adc3_dat       => rc4_adc3_dat,
--         adc4_dat       => rc4_adc4_dat,
--         adc5_dat       => rc4_adc5_dat,
--         adc6_dat       => rc4_adc6_dat,
--         adc7_dat       => rc4_adc7_dat,
--         adc8_dat       => rc4_adc8_dat,
--         adc1_ovr       => rc4_adc1_ovr,
--         adc2_ovr       => rc4_adc2_ovr,
--         adc3_ovr       => rc4_adc3_ovr,
--         adc4_ovr       => rc4_adc4_ovr,
--         adc5_ovr       => rc4_adc5_ovr,
--         adc6_ovr       => rc4_adc6_ovr,
--         adc7_ovr       => rc4_adc7_ovr,
--         adc8_ovr       => rc4_adc8_ovr,
--         adc1_rdy       => rc4_adc1_rdy,
--         adc2_rdy       => rc4_adc2_rdy,
--         adc3_rdy       => rc4_adc3_rdy,
--         adc4_rdy       => rc4_adc4_rdy,
--         adc5_rdy       => rc4_adc5_rdy,
--         adc6_rdy       => rc4_adc6_rdy,
--         adc7_rdy       => rc4_adc7_rdy,
--         adc8_rdy       => rc4_adc8_rdy,
--         adc1_clk       => rc4_adc1_clk,
--         adc2_clk       => rc4_adc2_clk,
--         adc3_clk       => rc4_adc3_clk,
--         adc4_clk       => rc4_adc4_clk,
--         adc5_clk       => rc4_adc5_clk,
--         adc6_clk       => rc4_adc6_clk,
--         adc7_clk       => rc4_adc7_clk,
--         adc8_clk       => rc4_adc8_clk,
--         dac_FB1_dat    => rc4_dac_FB1_dat,
--         dac_FB2_dat    => rc4_dac_FB2_dat,
--         dac_FB3_dat    => rc4_dac_FB3_dat,
--         dac_FB4_dat    => rc4_dac_FB4_dat,
--         dac_FB5_dat    => rc4_dac_FB5_dat,
--         dac_FB6_dat    => rc4_dac_FB6_dat,
--         dac_FB7_dat    => rc4_dac_FB7_dat,
--         dac_FB8_dat    => rc4_dac_FB8_dat,
--         dac_FB_clk     => rc4_dac_FB_clk,
--         dac_clk        => rc4_dac_clk,
--         dac_dat        => rc4_dac_dat,
--         bias_dac_ncs   => rc4_bias_dac_ncs,
--         offset_dac_ncs => rc4_offset_dac_ncs,
--         lvds_cmd       => lvds_cmd,
--         lvds_sync      => lvds_sync,
--         lvds_spare     => lvds_spare,
--         lvds_txa       => rc4_lvds_txa,
--         lvds_txb       => rc4_lvds_txb,
--
--         ttl_dir1       => rc4_ttl_dir1,
--         ttl_in1        => bclr_n, 
--         ttl_out1       => open,
--                           
--         ttl_dir2       => rc4_ttl_dir2,
--         ttl_in2        => rc4_ttl_in2, 
--         ttl_out2       => open,
--                           
--         ttl_dir3       => rc4_ttl_dir3,
--         ttl_in3        => rc4_ttl_in3, 
--         ttl_out3       => open,
--                      
--         red_led        => rc4_red_led,
--         ylw_led        => rc4_ylw_led,
--         grn_led        => rc4_grn_led,
--         dip_sw3        => rc4_dip_sw3,
--         dip_sw4        => rc4_dip_sw4,
--         wdog           => rc4_wdog,
--         slot_id        => rc4_slot_id,
--         card_id        => rc4_card_id,
--         mictor         => rc4_mictor
--      );
--
--   i_readout_card3: readout_card
--      generic map (
--         CARD => READOUT_CARD_3
--      )
--      port map (
--         rst_n          => rst_n,
--         inclk          => lvds_clk,
--         adc1_dat       => rc3_adc1_dat,
--         adc2_dat       => rc3_adc2_dat,
--         adc3_dat       => rc3_adc3_dat,
--         adc4_dat       => rc3_adc4_dat,
--         adc5_dat       => rc3_adc5_dat,
--         adc6_dat       => rc3_adc6_dat,
--         adc7_dat       => rc3_adc7_dat,
--         adc8_dat       => rc3_adc8_dat,
--         adc1_ovr       => rc3_adc1_ovr,
--         adc2_ovr       => rc3_adc2_ovr,
--         adc3_ovr       => rc3_adc3_ovr,
--         adc4_ovr       => rc3_adc4_ovr,
--         adc5_ovr       => rc3_adc5_ovr,
--         adc6_ovr       => rc3_adc6_ovr,
--         adc7_ovr       => rc3_adc7_ovr,
--         adc8_ovr       => rc3_adc8_ovr,
--         adc1_rdy       => rc3_adc1_rdy,
--         adc2_rdy       => rc3_adc2_rdy,
--         adc3_rdy       => rc3_adc3_rdy,
--         adc4_rdy       => rc3_adc4_rdy,
--         adc5_rdy       => rc3_adc5_rdy,
--         adc6_rdy       => rc3_adc6_rdy,
--         adc7_rdy       => rc3_adc7_rdy,
--         adc8_rdy       => rc3_adc8_rdy,
--         adc1_clk       => rc3_adc1_clk,
--         adc2_clk       => rc3_adc2_clk,
--         adc3_clk       => rc3_adc3_clk,
--         adc4_clk       => rc3_adc4_clk,
--         adc5_clk       => rc3_adc5_clk,
--         adc6_clk       => rc3_adc6_clk,
--         adc7_clk       => rc3_adc7_clk,
--         adc8_clk       => rc3_adc8_clk,
--         dac_FB1_dat    => rc3_dac_FB1_dat,
--         dac_FB2_dat    => rc3_dac_FB2_dat,
--         dac_FB3_dat    => rc3_dac_FB3_dat,
--         dac_FB4_dat    => rc3_dac_FB4_dat,
--         dac_FB5_dat    => rc3_dac_FB5_dat,
--         dac_FB6_dat    => rc3_dac_FB6_dat,
--         dac_FB7_dat    => rc3_dac_FB7_dat,
--         dac_FB8_dat    => rc3_dac_FB8_dat,
--         dac_FB_clk     => rc3_dac_FB_clk,
--         dac_clk        => rc3_dac_clk,
--         dac_dat        => rc3_dac_dat,
--         bias_dac_ncs   => rc3_bias_dac_ncs,
--         offset_dac_ncs => rc3_offset_dac_ncs,
--         lvds_cmd       => lvds_cmd,
--         lvds_sync      => lvds_sync,
--         lvds_spare     => lvds_spare,
--         lvds_txa       => rc3_lvds_txa,
--         lvds_txb       => rc3_lvds_txb,
--
--         ttl_dir1       => rc3_ttl_dir1,
--         ttl_in1        => bclr_n, 
--         ttl_out1       => open,
--                           
--         ttl_dir2       => rc3_ttl_dir2,
--         ttl_in2        => rc3_ttl_in2, 
--         ttl_out2       => open,
--                           
--         ttl_dir3       => rc3_ttl_dir3,
--         ttl_in3        => rc3_ttl_in3, 
--         ttl_out3       => open,
--                      
--         red_led        => rc3_red_led,
--         ylw_led        => rc3_ylw_led,
--         grn_led        => rc3_grn_led,
--         dip_sw3        => rc3_dip_sw3,
--         dip_sw4        => rc3_dip_sw4,
--         wdog           => rc3_wdog,
--         slot_id        => rc3_slot_id,
--         card_id        => rc3_card_id,
--         mictor         => rc3_mictor
--      );
--
--   i_readout_card2: readout_card
--      generic map (
--         CARD => READOUT_CARD_2
--      )
--      port map (
--         rst_n          => rst_n,
--         inclk          => lvds_clk,
--         adc1_dat       => rc2_adc1_dat,
--         adc2_dat       => rc2_adc2_dat,
--         adc3_dat       => rc2_adc3_dat,
--         adc4_dat       => rc2_adc4_dat,
--         adc5_dat       => rc2_adc5_dat,
--         adc6_dat       => rc2_adc6_dat,
--         adc7_dat       => rc2_adc7_dat,
--         adc8_dat       => rc2_adc8_dat,
--         adc1_ovr       => rc2_adc1_ovr,
--         adc2_ovr       => rc2_adc2_ovr,
--         adc3_ovr       => rc2_adc3_ovr,
--         adc4_ovr       => rc2_adc4_ovr,
--         adc5_ovr       => rc2_adc5_ovr,
--         adc6_ovr       => rc2_adc6_ovr,
--         adc7_ovr       => rc2_adc7_ovr,
--         adc8_ovr       => rc2_adc8_ovr,
--         adc1_rdy       => rc2_adc1_rdy,
--         adc2_rdy       => rc2_adc2_rdy,
--         adc3_rdy       => rc2_adc3_rdy,
--         adc4_rdy       => rc2_adc4_rdy,
--         adc5_rdy       => rc2_adc5_rdy,
--         adc6_rdy       => rc2_adc6_rdy,
--         adc7_rdy       => rc2_adc7_rdy,
--         adc8_rdy       => rc2_adc8_rdy,
--         adc1_clk       => rc2_adc1_clk,
--         adc2_clk       => rc2_adc2_clk,
--         adc3_clk       => rc2_adc3_clk,
--         adc4_clk       => rc2_adc4_clk,
--         adc5_clk       => rc2_adc5_clk,
--         adc6_clk       => rc2_adc6_clk,
--         adc7_clk       => rc2_adc7_clk,
--         adc8_clk       => rc2_adc8_clk,
--         dac_FB1_dat    => rc2_dac_FB1_dat,
--         dac_FB2_dat    => rc2_dac_FB2_dat,
--         dac_FB3_dat    => rc2_dac_FB3_dat,
--         dac_FB4_dat    => rc2_dac_FB4_dat,
--         dac_FB5_dat    => rc2_dac_FB5_dat,
--         dac_FB6_dat    => rc2_dac_FB6_dat,
--         dac_FB7_dat    => rc2_dac_FB7_dat,
--         dac_FB8_dat    => rc2_dac_FB8_dat,
--         dac_FB_clk     => rc2_dac_FB_clk,
--         dac_clk        => rc2_dac_clk,
--         dac_dat        => rc2_dac_dat,
--         bias_dac_ncs   => rc2_bias_dac_ncs,
--         offset_dac_ncs => rc2_offset_dac_ncs,
--         lvds_cmd       => lvds_cmd,
--         lvds_sync      => lvds_sync,
--         lvds_spare     => lvds_spare,
--         lvds_txa       => rc2_lvds_txa,
--         lvds_txb       => rc2_lvds_txb,
--
--         ttl_dir1       => rc2_ttl_dir1,
--         ttl_in1        => bclr_n, 
--         ttl_out1       => open,
--                           
--         ttl_dir2       => rc2_ttl_dir2,
--         ttl_in2        => rc2_ttl_in2, 
--         ttl_out2       => open,
--                           
--         ttl_dir3       => rc2_ttl_dir3,
--         ttl_in3        => rc2_ttl_in3, 
--         ttl_out3       => open,
--                      
--         red_led        => rc2_red_led,
--         ylw_led        => rc2_ylw_led,
--         grn_led        => rc2_grn_led,
--         dip_sw3        => rc2_dip_sw3,
--         dip_sw4        => rc2_dip_sw4,
--         wdog           => rc2_wdog,
--         slot_id        => rc2_slot_id,
--         card_id        => rc2_card_id,
--         mictor         => rc2_mictor
--      );
--
   i_readout_card1: readout_card
      generic map (
         CARD => READOUT_CARD_1
      )
      port map (
         rst_n          => rst_n,
         inclk          => lvds_clk,
         adc1_dat       => rc1_adc1_dat,
         adc2_dat       => rc1_adc2_dat,
         adc3_dat       => rc1_adc3_dat,
         adc4_dat       => rc1_adc4_dat,
         adc5_dat       => rc1_adc5_dat,
         adc6_dat       => rc1_adc6_dat,
         adc7_dat       => rc1_adc7_dat,
         adc8_dat       => rc1_adc8_dat,
         adc1_ovr       => rc1_adc1_ovr,
         adc2_ovr       => rc1_adc2_ovr,
         adc3_ovr       => rc1_adc3_ovr,
         adc4_ovr       => rc1_adc4_ovr,
         adc5_ovr       => rc1_adc5_ovr,
         adc6_ovr       => rc1_adc6_ovr,
         adc7_ovr       => rc1_adc7_ovr,
         adc8_ovr       => rc1_adc8_ovr,
         adc1_rdy       => rc1_adc1_rdy,
         adc2_rdy       => rc1_adc2_rdy,
         adc3_rdy       => rc1_adc3_rdy,
         adc4_rdy       => rc1_adc4_rdy,
         adc5_rdy       => rc1_adc5_rdy,
         adc6_rdy       => rc1_adc6_rdy,
         adc7_rdy       => rc1_adc7_rdy,
         adc8_rdy       => rc1_adc8_rdy,
         adc1_clk       => rc1_adc1_clk,
         adc2_clk       => rc1_adc2_clk,
         adc3_clk       => rc1_adc3_clk,
         adc4_clk       => rc1_adc4_clk,
         adc5_clk       => rc1_adc5_clk,
         adc6_clk       => rc1_adc6_clk,
         adc7_clk       => rc1_adc7_clk,
         adc8_clk       => rc1_adc8_clk,
         dac_FB1_dat    => rc1_dac_FB1_dat,
         dac_FB2_dat    => rc1_dac_FB2_dat,
         dac_FB3_dat    => rc1_dac_FB3_dat,
         dac_FB4_dat    => rc1_dac_FB4_dat,
         dac_FB5_dat    => rc1_dac_FB5_dat,
         dac_FB6_dat    => rc1_dac_FB6_dat,
         dac_FB7_dat    => rc1_dac_FB7_dat,
         dac_FB8_dat    => rc1_dac_FB8_dat,
         dac_FB_clk     => rc1_dac_FB_clk,
         dac_clk        => rc1_dac_clk,
         dac_dat        => rc1_dac_dat,
         bias_dac_ncs   => rc1_bias_dac_ncs,
         offset_dac_ncs => rc1_offset_dac_ncs,
         lvds_cmd       => lvds_cmd,
         lvds_sync      => lvds_sync,
         lvds_spare     => lvds_spare,
         lvds_txa       => rc1_lvds_txa,
         lvds_txb       => rc1_lvds_txb,

         ttl_dir1       => rc1_ttl_dir1,
         ttl_in1        => bclr_n, 
         ttl_out1       => open,
                           
         ttl_dir2       => rc1_ttl_dir2,
         ttl_in2        => rc1_ttl_in2, 
         ttl_out2       => open,
                           
         ttl_dir3       => rc1_ttl_dir3,
         ttl_in3        => rc1_ttl_in3, 
         ttl_out3       => open,
                      
         red_led        => rc1_red_led,
         ylw_led        => rc1_ylw_led,
         grn_led        => rc1_grn_led,
         dip_sw3        => rc1_dip_sw3,
         dip_sw4        => rc1_dip_sw4,
         wdog           => rc1_wdog,
         slot_id        => rc1_slot_id,
         card_id        => rc1_card_id,
         mictor         => rc1_mictor
      );
--
--   i_bias_card3: bias_card
--      port map
--      (
--         -- PLL input:
--         inclk         => lvds_clk,
--         rst_n         => rst_n,
--         
--         -- LVDS interface:
--         lvds_cmd      => lvds_cmd,  
--         lvds_sync     => lvds_sync, 
--         lvds_spare    => lvds_spare,
--         lvds_txa      => lvds_reply_bc3_a, 
--         lvds_txb      => lvds_reply_bc3_b, 
--         
--         -- TTL interface:
--         ttl_nrx1      => bclr_n,  
--         ttl_tx1       => open,   
--         ttl_txena1    => bc3_ttl_txena1,
--
--         ttl_nrx2      => bc3_ttl_nrx2,  
--         ttl_tx2       => open,   
--         ttl_txena2    => bc3_ttl_txena2,
--
--         ttl_nrx3      => bc3_ttl_nrx3,  
--         ttl_tx3       => open,   
--         ttl_txena3    => bc3_ttl_txena3,
--         
--         -- eeprom ice:nterface:
--         eeprom_si     => bc3_eeprom_si, 
--         eeprom_so     => bc3_eeprom_so, 
--         eeprom_sck    => bc3_eeprom_sck,
--         eeprom_cs     => bc3_eeprom_cs, 
--         
--         -- dac interface:
--         dac_ncs       => bc3_dac_ncs,      
--         dac_sclk      => bc3_dac_sclk,     
--         dac_data      => bc3_dac_data,         
--         lvds_dac_ncs  => bc3_lvds_dac_ncs, 
--         lvds_dac_sclk => bc3_lvds_dac_sclk,
--         lvds_dac_data => bc3_lvds_dac_data,
--         dac_nclr      => bc3_dac_nclr,     
--         
--         -- miscellaneous ports:
--         red_led       => bc3_red_led, 
--         ylw_led       => bc3_ylw_led, 
--         grn_led       => bc3_grn_led, 
--         dip_sw3       => bc3_dip_sw3, 
--         dip_sw4       => bc3_dip_sw4, 
--         wdog          => bc3_wdog,    
--         slot_id       => bc3_slot_id, 
--         
--         -- debug ports:
--         test          => bc3_test,       
--         mictor        => bc3_mictor,     
--         mictorclk     => bc3_mictorclk,  
--         rx            => bc3_rs232_rx,
--         tx            => bc3_rs232_tx
--      );   
--
--   i_bias_card2: bias_card
--      port map
--      (
--         -- PLL input:
--         inclk         => lvds_clk,
--         rst_n         => rst_n,
--         
--         -- LVDS interface:
--         lvds_cmd      => lvds_cmd,  
--         lvds_sync     => lvds_sync, 
--         lvds_spare    => lvds_spare,
--         lvds_txa      => lvds_reply_bc2_a, 
--         lvds_txb      => lvds_reply_bc2_b, 
--         
--         -- TTL interface:
--         ttl_nrx1      => bclr_n,  
--         ttl_tx1       => open,   
--         ttl_txena1    => bc2_ttl_txena1,
--
--         ttl_nrx2      => bc2_ttl_nrx2,  
--         ttl_tx2       => open,   
--         ttl_txena2    => bc2_ttl_txena2,
--
--         ttl_nrx3      => bc2_ttl_nrx3,  
--         ttl_tx3       => open,   
--         ttl_txena3    => bc2_ttl_txena3,
--         
--         -- eeprom ice:nterface:
--         eeprom_si     => bc2_eeprom_si, 
--         eeprom_so     => bc2_eeprom_so, 
--         eeprom_sck    => bc2_eeprom_sck,
--         eeprom_cs     => bc2_eeprom_cs, 
--         
--         -- dac interface:
--         dac_ncs       => bc2_dac_ncs,      
--         dac_sclk      => bc2_dac_sclk,     
--         dac_data      => bc2_dac_data,         
--         lvds_dac_ncs  => bc2_lvds_dac_ncs, 
--         lvds_dac_sclk => bc2_lvds_dac_sclk,
--         lvds_dac_data => bc2_lvds_dac_data,
--         dac_nclr      => bc2_dac_nclr,     
--         
--         -- miscellaneous ports:
--         red_led       => bc2_red_led, 
--         ylw_led       => bc2_ylw_led, 
--         grn_led       => bc2_grn_led, 
--         dip_sw3       => bc2_dip_sw3, 
--         dip_sw4       => bc2_dip_sw4, 
--         wdog          => bc2_wdog,    
--         slot_id       => bc2_slot_id, 
--         
--         -- debug ports:
--         test          => bc2_test,       
--         mictor        => bc2_mictor,     
--         mictorclk     => bc2_mictorclk,  
--         rx            => bc2_rs232_rx,
--         tx            => bc2_rs232_tx
--      );     
--
   i_bias_card1: bias_card
      port map
      (
         -- PLL input:
         inclk         => lvds_clk,
         rst_n         => rst_n,
         
         -- LVDS interface:
         lvds_cmd      => lvds_cmd,  
         lvds_sync     => lvds_sync, 
         lvds_spare    => lvds_spare,
         lvds_txa      => lvds_reply_bc1_a, 
         lvds_txb      => lvds_reply_bc1_b, 
         
         -- TTL interface:
         ttl_nrx1      => bclr_n,  
         ttl_tx1       => open,   
         ttl_txena1    => bc1_ttl_txena1,

         ttl_nrx2      => bc1_ttl_nrx2,  
         ttl_tx2       => open,   
         ttl_txena2    => bc1_ttl_txena2,

         ttl_nrx3      => bc1_ttl_nrx3,  
         ttl_tx3       => open,   
         ttl_txena3    => bc1_ttl_txena3,
         
         -- eeprom ice:nterface:
         eeprom_si     => bc1_eeprom_si, 
         eeprom_so     => bc1_eeprom_so, 
         eeprom_sck    => bc1_eeprom_sck,
         eeprom_cs     => bc1_eeprom_cs, 
         
         -- dac interface:
         dac_ncs       => bc1_dac_ncs,      
         dac_sclk      => bc1_dac_sclk,     
         dac_data      => bc1_dac_data,         
         lvds_dac_ncs  => bc1_lvds_dac_ncs, 
         lvds_dac_sclk => bc1_lvds_dac_sclk,
         lvds_dac_data => bc1_lvds_dac_data,
         dac_nclr      => bc1_dac_nclr,     
         
         -- miscellaneous ports:
         red_led       => bc1_red_led, 
         ylw_led       => bc1_ylw_led, 
         grn_led       => bc1_grn_led, 
         dip_sw3       => bc1_dip_sw3, 
         dip_sw4       => bc1_dip_sw4, 
         wdog          => bc1_wdog,    
         slot_id       => bc1_slot_id, 
         
         -- debug ports:
         test          => bc1_test,       
         mictor        => bc1_mictor,     
         mictorclk     => bc1_mictorclk,  
         rx            => bc1_rs232_rx,
         tx            => bc1_rs232_tx
      );     
--
--   i_addr_card : addr_card
--      port map
--      (
--         -- PLL input:
--         inclk            => lvds_clk,
--         rst_n            => rst_n,
--         
--         -- LVDS interface:
--         lvds_cmd         => lvds_cmd,  
--         lvds_sync        => lvds_sync, 
--         lvds_spare       => lvds_spare,
--         lvds_txa         => lvds_reply_ac_a, 
--         lvds_txb         => lvds_reply_ac_b, 
--      
--         -- TTL interface:
--         ttl_nrx1         => bclr_n,
--         ttl_tx1          => open,
--         ttl_txena1       => ac_ttl_txena1,
--         
--         ttl_nrx2         => ac_ttl_nrx2,
--         ttl_tx2          => open,
--         ttl_txena2       => ac_ttl_txena2,
--         
--         ttl_nrx3         => ac_ttl_nrx3,
--         ttl_tx3          => open,
--         ttl_txena3       => ac_ttl_txena3,
--         
--         -- eeprom interface:
--         eeprom_si        => ac_eeprom_si, 
--         eeprom_so        => ac_eeprom_so, 
--         eeprom_sck       => ac_eeprom_sck,
--         eeprom_cs        => ac_eeprom_cs, 
--         
--         -- dac interface:
--         dac_data0        => ac_dac_data0,  
--         dac_data1        => ac_dac_data1,  
--         dac_data2        => ac_dac_data2,  
--         dac_data3        => ac_dac_data3,  
--         dac_data4        => ac_dac_data4,  
--         dac_data5        => ac_dac_data5,  
--         dac_data6        => ac_dac_data6,  
--         dac_data7        => ac_dac_data7,  
--         dac_data8        => ac_dac_data8,  
--         dac_data9        => ac_dac_data9,  
--         dac_data10       => ac_dac_data10, 
--         dac_clk          => ac_dac_clk,    
--         
--         -- miscellaneous ports:
--         red_led          => ac_red_led, 
--         ylw_led          => ac_ylw_led, 
--         grn_led          => ac_grn_led, 
--         dip_sw3          => ac_dip_sw3, 
--         dip_sw4          => ac_dip_sw4, 
--         wdog             => ac_wdog,    
--         slot_id          => ac_slot_id, 
--         
--         -- debug ports:
--         test             => ac_test,       
--         mictor           => ac_mictor,     
--         mictorclk        => ac_mictorclk,  
--         rs232_rx         => ac_rs232_rx,
--         rs232_tx         => ac_rs232_tx
--      );
     
   ------------------------------------------------
   -- Create test bench stimuli
   -------------------------------------------------
   
   stimuli : process

   procedure do_reset is
   begin
      -- setup the hotlink receiver to receive the special character
      fibre_rx_sc_nd  <= '1';
      fibre_rx_status <= '1';
      fibre_rx_rvs    <= '0';

      -- special case for the reset character
      fibre_rx_rdy    <= '0';  -- data not ready (active low)
      fibre_rx_data   <= SPEC_CHAR_RESET;
      
      wait for fibre_clkr_prd * 0.4;
      
      -- set up hotlink receiver signals 
      fibre_rx_sc_nd  <= '0';
      fibre_rx_status <= '1';
      fibre_rx_rvs    <= '0';

      -- set default values for input
      fibre_rx_rdy    <= '0';  -- data not ready (active low)
      fibre_rx_data   <= x"00";
 
      wait for fibre_clkr_prd * 0.6;



      rst_n <= '0';
      wait for clk_period*5 ;
      rst_n <= '1';
      wait for clk_period*5 ;   
      assert false report " Resetting the DUT." severity NOTE;
      
   end do_reset;
   --------------------------------------------------
  
   procedure load_preamble is
   begin
   
   for I in 0 to 3 loop
      fibre_rx_rdy    <= '1';  -- data not ready (active low)
      fibre_rx_data  <= preamble1;
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;   
   
   for I in 0 to 3 loop
      fibre_rx_rdy    <= '1';  -- data not ready (active low)
      fibre_rx_data  <= preamble2;
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;     
   
   fibre_rx_rdy <= '1';
   wait for pci_dsp_dly;     
    
   assert false report "preamble OK" severity NOTE;
   end load_preamble;
   
   ---------------------------------------------------------    
 
   procedure load_command is 
   begin   
      checksum  <= command;
    
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
    
      assert false report "command code loaded" severity NOTE;
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly;   
     
      -- load up address_id
      checksum <= checksum XOR address_id;
     
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
     
      assert false report "address id loaded" severity NOTE;
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly; 
     
      -- load up data valid       
      checksum <= checksum XOR data_valid;
  
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      assert false report "data valid loaded" severity NOTE;
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly; 
      
      -- load up data block
      -- first load valid data
      for I in 0 to (conv_integer(data_valid)-1) loop
      --for I in 0 to (data_valid-1) loop
         
         fibre_rx_rdy   <= '1';
         
         fibre_rx_data <= data(7 downto 0);
         checksum (7 downto 0) <= checksum (7 downto 0) XOR data(7 downto 0);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         
         fibre_rx_data <= data(15 downto 8);
         checksum (15 downto 8) <= checksum (15 downto 8) XOR data(15 downto 8);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';

         fibre_rx_data <= data(23 downto 16);
         checksum (23 downto 16) <= checksum (23 downto 16) XOR data(23 downto 16);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         
         fibre_rx_data <= data(31 downto 24);
         checksum (31 downto 24) <= checksum (31 downto 24) XOR data(31 downto 24);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         
         case address_id is
            when cc_ret_dat_s_cmd => data <= ret_dat_s_stop;
            when rc1_ret_dat_cmd  => data <= (others => '0');
            when rc2_ret_dat_cmd  => data <= (others => '0');
            when rc3_ret_dat_cmd  => data <= (others => '0');
            when rc4_ret_dat_cmd  => data <= (others => '0');
            when rcs_ret_dat_cmd  => data <= (others => '0');
            when others           => data <= data + 1;
         end case;
         
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy <= '1';
         wait for pci_dsp_dly;        
      end loop;
    
      for J in (conv_integer(data_valid)) to data_block-1 loop
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
            
         fibre_rx_rdy <= '1';
         wait for pci_dsp_dly; 
      end loop;
        
      assert false report "data words loaded to memory...." severity NOTE;

   end load_command;
    
   ------------------------------------------------------
   procedure load_checksum is
    
      begin 
         
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
         
      assert false report "checksum loaded...." severity NOTE;  
       
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly; 
   
   end load_checksum;
       
   ------------------------------------------------------
   procedure block_sync is
   begin 
         
      sync_en <= "01";
      wait for clk_period*41*64;
      sync_en <= "00";
      wait for clk_period;
   
   end block_sync;
  
   ------------------------------------------------------
   procedure noisy_sync_proc is
   begin 
         
      sync_en <= "10";
      noisy_sync <= '1';
      wait for clk_period;
      noisy_sync <= '0';
      wait for clk_period;
      noisy_sync <= '0';
      wait for clk_period;
      noisy_sync <= '0';
      wait for clk_period;
      sync_en <= "00";
      wait for clk_period;
   
   end noisy_sync_proc;
   

--------------------------------------------------------
-- Begin Test
------------------------------------------------------      
       
   begin
      
      do_reset;
      wait for 5 us;

------------------------------------------------------
--  Test Case xx: For testing bias card commands
--  wb bc1 flux_fb 3 ..
--  wb bc1 bias 3 
--  rb bc1 flux_fb 
--  rb bc1 bias
--  wb bc1 flux_fb 100 ...
------------------------------------------------------
--      command <= command_wb;
--      address_id <= bc1_flux_fb_cmd;
--      data_valid <= X"00000020";
--      data       <= X"00000003";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--      
--      command <= command_wb;
--      address_id <= bc1_bias_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000008";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 20 us;
--
--      command <= command_rb;
--      address_id <= bc1_flux_fb_cmd;
--      data_valid <= X"00000020";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--      
--      command <= command_rb;
--      address_id <= bc1_bias_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 20 us;
--
--      command <= command_wb;
--      address_id <= bc1_flux_fb_cmd;
--      data_valid <= X"00000020";
--      data       <= X"00000064";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 200 us;
            
      
------------------------------------------------------
--  For testing internal commands
------------------------------------------------------
--   constant cc_tes_tgl_en_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_EN_ADDR;
--   constant cc_tes_tgl_max_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_MAX_ADDR;
--   constant cc_tes_tgl_min_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_MIN_ADDR;
--   constant cc_tes_tgl_rate_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_RATE_ADDR;
--   constant cc_int_cmd_en_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & INT_CMD_EN_ADDR;

      command <= command_wb;
      address_id <= all_row_len_cmd;
      data_valid <= X"00000001";
      data       <= X"00000080";
      load_preamble;
      load_command;
      load_checksum;
      wait for 125 us;
      
      command <= command_wb;
      address_id <= all_num_rows_cmd;
      data_valid <= X"00000001";
      data       <= X"00000004";
      load_preamble;
      load_command;
      load_checksum;
      wait for 125 us;

      command    <= command_wb;
      address_id <= cc_tes_tgl_max_cmd;
      data_valid <= X"00000001";
      data       <= X"00002222";
      load_preamble;
      load_command;
      load_checksum;
      wait for 20 us;

      command    <= command_wb;
      address_id <= cc_tes_tgl_min_cmd;
      data_valid <= X"00000001";
      data       <= X"00001111";
      load_preamble;
      load_command;
      load_checksum;
      wait for 20 us;

      command    <= command_wb;
      address_id <= cc_tes_tgl_rate_cmd;
      data_valid <= X"00000001";
      data       <= X"00000040";
      load_preamble;
      load_command;
      load_checksum;
      wait for 20 us;

      command    <= command_wb;
      address_id <= cc_tes_tgl_en_cmd;
      data_valid <= X"00000001";
      data       <= X"00000001";
      load_preamble;
      load_command;
      load_checksum;
      wait for 20 us;

      command <= command_wb;
      address_id <= cc_ret_dat_s_cmd;
      data_valid <= X"00000002";
      data       <= X"00000002";
      load_preamble;
      load_command;
      load_checksum;
      wait for 20 us;

      command <= command_wb;
      address_id <= cc_data_rate_cmd;
      data_valid <= X"00000001";
      data       <= X"00000020";
      load_preamble;
      load_command;
      load_checksum;
      wait for 600 us;

      command <= command_go;
      address_id <= rc1_ret_dat_cmd;
      data_valid <= X"00000001";
      data       <= X"00000001";
      load_preamble;
      load_command;
      load_checksum;
      wait for 10000 us;

------------------------------------------------------
--  Testing Clock Selection Commands
------------------------------------------------------
--      command <= command_rb;
--      address_id <= cc_select_clk_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;          
--      wait for 20 us;
--
--      command <= command_wb;
--      address_id <= cc_select_clk_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;          
--      wait for 20 us;
--
--      command <= command_rb;
--      address_id <= cc_select_clk_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;          
--      wait for 20 us;
--
--      command <= command_wb;
--      address_id <= cc_select_clk_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;          
--      wait for 20 us;
--
--      command <= command_rb;
--      address_id <= cc_select_clk_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;          
--      wait for 20 us;

------------------------------------------------------
--  For Measuring the time needed for the longest command possible (58 words)
--  Used for specifying MIN_WINDOW
------------------------------------------------------
--      command <= command_wb;
--      address_id <= cc_led_cmd;
--      data_valid <= X"0000003A";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;            
--      wait for 125 us;
--
--      command <= command_rb;
--      address_id <= cc_row_len_cmd;
--      data_valid <= X"0000003A";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 125 us;

------------------------------------------------------
--  Testing New Fibre Protocol
------------------------------------------------------
--      command <= command_rs;
--      address_id <= psu_cycle_pow_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 300 us;
--
--      command <= command_wb;
--      address_id <= cc_led_cmd;
--      data_valid <= X"0000003A";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;            
--      wait for 125 us;
--
--      command <= command_wb;
--      address_id <= ac_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;            
--      wait for 250 us;
-- 
--      command <= command_rb;
--      address_id <= cc_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;            
--      wait for 15 us;
--
--      -- From Manchester = 2
--      command <= command_wb;
--      address_id <= cc_use_dv_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000002";
--      load_preamble;
--      load_command;
--      load_checksum;            
--      wait for 53 us;
--
--      command <= command_wb;
--      address_id <= cc_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;            
--      wait for 15 us;
--
--      command <= command_rb;
--      address_id <= cc_row_len_cmd;
--      data_valid <= X"0000003A";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 125 us;
--
--      command <= command_go;
--      address_id <= rc1_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 1200 us;
--
--      command <= command_go;
--      address_id <= rc2_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 600 us;

------------------------------------------------------
--  PSU Testing
------------------------------------------------------
--   constant psu_brst_mce_cmd        : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & BRST_MCE_ADDR;
--   constant psu_cycle_pow_cmd       : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & CYCLE_POW_ADDR;
--   constant psu_cut_pow_cmd         : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & CUT_POW_ADDR;
--   constant psu_status_cmd          : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & PSC_STATUS_ADDR;

--      command <= command_rs;
--      address_id <= psu_brst_mce_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 300 us;
--
--      command <= command_rs;
--      address_id <= psu_cycle_pow_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 300 us;
--
--      command <= command_rs;
--      address_id <= psu_cut_pow_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 300 us;
--
--      command <= command_rb;
--      address_id <= psu_status_cmd;
--      data_valid <= X"00000009";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 300 us;
--
--      command <= command_rb;
--      address_id <= psu_status_cmd;
--      data_valid <= X"00000009";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 300 us;
--      wait for 300 us;

------------------------------------------------------
--  Testing Manchester Data Packets
------------------------------------------------------
----      manchester_data   : in std_logic;
----      manchester_sigdet : in std_logic;
--
--      
----      constant DV_INTERNAL            : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
----      constant DV_EXTERNAL_FIBRE      : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";
----      constant DV_EXTERNAL_MANCHESTER : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "10";
--
--
--      command <= command_wb;
--      address_id <= rc1_gainp0_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      
--      wait for 15 us;

--      command <= command_wb;
--      address_id <= rc1_gainp1_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000002";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      
--      wait for 53 us;
--
--      command <= command_wb;
--      address_id <= cc_ret_dat_s_cmd;
--      data_valid <= X"00000002";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= cc_data_rate_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= all_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"000003E8";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 125 us;
--      
--      command <= command_rb;
--      address_id <= all_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"000003E8";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 125 us;
--
--      cc_dip_sw3 <= '0';
--      cc_dip_sw4 <= '1';
--      
--      command <= command_wb;
--      address_id <= cc_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000004";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 250 us;
--
--      cc_dip_sw3 <= '1';
--      cc_dip_sw4 <= '0';
--      
--      command <= command_wb;
--      address_id <= cc_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000004";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 250 us;
--
--      command <= command_wb;
--      address_id <= rc1_num_rows_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000004";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= ac_num_rows_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000004";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= cc_num_rows_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000004";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= cc_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"000003E8";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= rc1_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"000003E8";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= rc1_sample_num_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_rb;
--      address_id <= rc1_sample_num_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= ac_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"000003E8";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--      
--      command <= command_wb;
--      address_id <= ac_row_order_cmd;
--      data_valid <= X"00000004";
--      data       <= X"0000000A";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--
--      command <= command_wb;
--      address_id <= ac_enbl_mux_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 15 us;
--      
--      command <= command_wb;
--      address_id <= rc1_servo_mode_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000003";
--      load_preamble;
--      load_command;
--      load_checksum;     
--      
--      wait for 15 us;
--      
--
--      -- From Manchester = 2
--      command <= command_wb;
--      address_id <= cc_use_dv_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000002";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      
--      wait for 53 us;
-- 
--      -- From Manchester = 2
--      command <= command_wb;
--      address_id <= cc_use_sync_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000002";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      
--      wait for 53 us;
--      
--      command <= command_go;
--      address_id <= rc1_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 1000 us;
      
      

------------------------------------------------------
--  Testing Clock Switchover
------------------------------------------------------
-- There are four scenarios to be tested:
-- if(using crystal clock)
--    if(crystal clock is good)
--       if(clock switch command)
--          if(manchester clock is good)
--             switch to manchester clock;
--          end if;
--       end if;
--    elsif(crystal clock is bad)
--       if(manchester clock is good)
--          switch to manchester clock;
--       end if;
--    end if;
-- elsif(using manchester clock)
--    if(mancheseter clock is good)
--       if(clock switch command)
--          if(crystal clock is good)
--             switch to crystal clock;
--          end if;
--       end if;
--    elsif(manchester clock is bad)
--       if(crystal clock is good)
--          switch to crystal clock;
--       end if;
--    end if;
-- end if;
       

--      wait for 50 us;
--      manchester_sigdet <= '1';      
----      wait for 50 us;
----      manchester_sigdet <= '0';      
--
--      wait for 50 us;
--      inclk_en <= '0';
--      
--      wait for 50 us;
--      inclk_en <= '1';
--
--      wait for 50 us;
----      switch_to_manch
--      switch_to_xtal <= '1';
--      wait for 20 ns;
--      switch_to_xtal <= '0';      
--
--      wait for 1000 us;

------------------------------------------------------
--  Testing Clock Card Reconfiguration from Factory/Application EPC16s
------------------------------------------------------
--      command <= command_rs;
--      address_id <= cc_config_fac_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 53 us;
--
--      do_reset;
--      wait for 5 us;
--
--      command <= command_rs;
--      address_id <= cc_config_app_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 53 us;

------------------------------------------------------
--  Command sequence for testing the PI loop on RC1
------------------------------------------------------
--      command <= command_wb;
--      address_id <= cc_num_rows_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000008";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--      
--      command <= command_wb;
--      address_id <= rc1_num_rows_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000008";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= cc_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000020";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--      
--      command <= command_wb;
--      address_id <= rc1_row_len_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000020";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= rc1_sample_dly_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000008";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= rc1_sample_num_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= rc1_servo_mode_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000003";
--      load_preamble;
--      load_command;
--      load_checksum;     
--      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= rc1_gainp0_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--
---- For testing the wbs_fb_data slave with buffers on it's dat_o and ack_o lines
----      command <= command_rb;
----      address_id <= rc1_gainp0_cmd;
----      data_valid <= X"00000005";
----      data       <= X"00000040";
----      load_preamble;
----      load_command;
----      load_checksum;
----      wait for 70 us;
--
--      command <= command_wb;
--      address_id <= rc1_gaini0_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--
----      command <= command_wb;
----      address_id <= rc1_en_fb_jump_cmd;
----      data_valid <= X"00000001"; -- 1 values
----      data       <= X"00000000";
----      load_preamble;
----      load_command;
----      load_checksum;
----      wait for 50 us;
----
----      
----      command <= command_wb;
----      address_id <= rc1_fltr_rst_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00000001";
----      load_preamble;
----      load_command;
----      load_checksum;
----      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= rc1_flx_lp_init_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 1000 us;

------------------------------------------------------
--  Command sequence for testing the flux feedback on RC1
------------------------------------------------------

--      command <= command_wb;
--      address_id <= rc1_flx_quanta0_cmd;
--      data_valid <= X"00000029"; -- 41 values
--      data       <= X"00001770"; -- 6000
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 100 us;
--      
--      command <= command_wb;
--      address_id <= rc1_en_fb_jump_cmd;
--      data_valid <= X"00000001"; -- 1 values
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= rc1_servo_mode_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;     
--
--      wait for 50 us;
--
----      command <= command_wb;
----      address_id <= rc1_data_mode_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00000001";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 50 us;
--
--
----   constant FSFB_MAX               : std_logic_vector(SUB_WIDTH-1 downto 0) := x"0000000000001E78"; --  7800
----   constant FSFB_MIN               : std_logic_vector(SUB_WIDTH-1 downto 0) := x"FFFFFFFFFFFFE188"; -- -7800
--      -- 5900  170c
--      -- 6000  1770
--      -- 6100  17d4
--      -- 6200  1838
--      -- 6300  189c
--      -- 7700  1e14
--      -- 7800  1e78
--      -- 7900  1edc
--      -- 8000  1f40
--      -- 14000 36b0
--      -- 16000 3e80
--      -- 17000 4268
--      -- 20000 4e20
--      -- 26000 6590
--      
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"0000170c";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
----
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00001770";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
----
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"000017d4";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
----
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00001838";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
--
--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000001";
--      data       <= X"0000189c";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--
--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00001e78";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--
--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00001edc";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00001f40";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
----
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00003e80";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
----
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00004e20";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
----
----      command <= command_wb;
----      address_id <= rc1_fb_const_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00006590";
----      load_preamble;
----      load_command;
----      load_checksum;
----      
----      wait for 100 us;
--
--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 100 us;
--
--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000001";
--      data       <= X"FFFFE188"; -- (-)7800
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--
--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000001";
--      data       <= X"FFFFE187"; -- (-)7801
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 500 us;
--
----      command <= command_go;
----      address_id <= rc1_ret_dat_cmd;
----      data_valid <= X"00000001";
----      data       <= X"00000001";
----      load_preamble;
----      load_command;
----      load_checksum;
----
----      wait for 1000 us;

------------------------------------------------------
--  Command sequence for testing frame header functionality on the CC
------------------------------------------------------
-- Internal commands must be enabled in cmd_translator

--      command <= command_wb;
--      address_id <= rc1_servo_mode_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;     
--      
--      wait for 50 us;
--      
--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000001";
--      data       <= X"0000AAAA";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 50 us;
--
--      command <= command_wb;
--      address_id <= rc1_data_mode_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 50 us;
--      
--      command <= command_wb;
--      address_id <= rc1_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 50 us;
--
--      command <= command_go;
--      address_id <= rc1_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 3200 us;

------------------------------------------------------
--  Command sequence for reproducing the bug found 14 Dec 2005
------------------------------------------------------
--      command <= command_wb;
--      address_id <= ac_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000005";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 54 us;
--      
--      command <= command_rb;
--      address_id <= ac_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000005";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 54 us;
--
--      command <= command_wb;
--      address_id <= cc_fw_rev_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      wait for 200 us;
--
--      command <= command_wb;
--      address_id <= cc_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      wait for 30 us;
--
--      command <= command_wb;
--      address_id <= rc1_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;

------------------------------------------------------
--  ret_dat testing
------------------------------------------------------
--      command <= command_wb;
--      address_id <= cc_data_rate_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000014";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      wait for 30 us;
--
--      command <= command_wb;
--      address_id <= cc_ret_dat_s_cmd;
--      data_valid <= X"00000002";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;        
--      wait for 30 us;
--
--      command <= command_go;
--      address_id <= rc1_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      wait for 2000 us;

------------------------------------------------------
--  DV Rx testing
------------------------------------------------------
--      constant DV_INTERNAL            : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
--      constant DV_EXTERNAL_FIBRE      : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";
--      constant DV_EXTERNAL_MANCHESTER : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "10";
--
--      command <= command_wb;
--      address_id <= cc_ret_dat_s_cmd;
--      data_valid <= X"00000002";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      wait for 53 us;
--
--      command <= command_wb;
--      address_id <= cc_use_dv_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000002";
--      load_preamble;
--      load_command;
--      load_checksum;      
--      wait for 53 us;
-- 
--      command <= command_go;
--      address_id <= rc1_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 150 us;
--
--      -- DV pulse is inverted by the receiver
--      -- Length of DV packet is 1600ns, 40ns per bit
--      manchester_data <= '0';
--      wait for 320 ns;
--      wait for 1240 ns; -- dv sequence # 1
--      manchester_data <= '1';      
--      wait for 900 us;
--      
--      manchester_data <= '0';
--      wait for 320 ns;
--      wait for 1200 ns; -- dv sequence # 2
--      manchester_data <= '1';      
--      wait for 900 us;
--
-- 
--      -- DV pulse is inverted by the receiver
--      dv_pulse_fibre <= '0';
--      wait for 1 us;
--      dv_pulse_fibre <= '1';      
--      wait for 1200 us;
--      
--      dv_pulse_fibre <= '0';
--      wait for 1 us;
--      dv_pulse_fibre <= '1';      
--      wait for 1200 us;
--
--      dv_pulse_fibre <= '0';
--      wait for 1 us;
--      dv_pulse_fibre <= '1';      
--      wait for 1200 us;
--
--      command <= command_wb;
--      address_id <= cc_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;

------------------------------------------------------
--  Command sequence for testing timeout recovery on the CC
------------------------------------------------------
-- Internal commands must be disabled in cmd_translator
-- The command timeout in reply_queue_sequencer must be set to 100us
--
--      command <= command_wb;
--      address_id <= cc_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--
--      command <= command_wb;
--      address_id <= rc1_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000006";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 54 us;
--      
--      command <= command_rb;
--      address_id <= rc1_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 54 us;
--
--      command <= command_wb;
--      address_id <= rc1_led_cmd;
--      data_valid <= X"0000000B";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--      
--      
--      command <= command_wb;
--      address_id <= rc2_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;
--      
--      command <= command_rb;
--      address_id <= rc2_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;
--
--      command <= command_wb;
--      address_id <= rcs_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;
--      
--      command <= command_rb;
--      address_id <= rcs_led_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;

--      command <= command_go;
--      address_id <= rc1_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 1000 us;
--
--      command <= command_go;
--      address_id <= rcs_ret_dat_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--
--      wait for 2000 us;

------------------------------------------------------
--  Command sequence for testing problems with either bc_v01020001 or rc_v03000004
------------------------------------------------------
--      command <= command_wb;
--      address_id <= rc1_offset_cmd;
--      data_valid <= X"00000008";
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;
--
--      command <= command_wb;
--      address_id <= rc1_sa_bias_cmd;
--      data_valid <= X"00000008";
--      data       <= X"00000002";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;
--
--      command <= command_wb;
--      address_id <= bc1_flux_fb_cmd;
--      data_valid <= X"00000020";
--      data       <= X"00000003";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;


      
      assert false report "Simulation done." severity FAILURE;
   end process stimuli;  


   --signal cc_mosii      : std_logic;
   --signal cc_sclki      : std_logic;
   --signal cc_ccssi      : std_logic;
   --signal cc_misoo      : std_logic;
   --signal cc_sreqo      : std_logic;

   -- This process emulates the behaviour of the psuc's ccss control signal
   -- This process runs concurrently to the command rx/tx process above
   -- This process waits for sreq to be asserted by the clock card before asserting ccss
   cc_sclki <= not cc_sclki after spi_clk_period/2;
   cc_mosii <= not cc_mosii after spi_clk_period;
   
   psuc : process   
      procedure wait_for_sreq is
      begin
         wait for spi_clk_period;
         if(cc_sreqo = '1') then
            cc_ccssi <= '1';
         else
            cc_ccssi <= '0';
         end if;
      end wait_for_sreq;
   begin
      loop wait_for_sreq;
      end loop;
   end process psuc;
   
--   manchester_input : process
--   
--      procedure manchester_sync_packet is
--      begin 
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '1';
--         wait for 40 ns;
--         manchester_data <= '1';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '1';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         
--         manchester_data <= '1';
--         wait for 50880 ns; -- Based on 41 rows, 64 cycles per row, 20 ns per cycle, minus 40 bits at 25 MHz
--      
--      end manchester_sync_packet;
--      
--      procedure manchester_data_packet is
--      begin 
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '1';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '1';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         manchester_data <= '0';
--         wait for 40 ns;
--         
--         manchester_data <= '1';
--         wait for 50880 ns; -- Based on 41 rows, 64 cycles per row, 20 ns per cycle, minus 40 bits at 25 MHz
--      
--      end manchester_data_packet;   
--   
--   begin
--
--      manchester_sigdet <= '1';
--
--      manchester_data_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      
--      manchester_data_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      
--      manchester_data_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      
--      manchester_data_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      
--      manchester_data_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      manchester_sync_packet;
--      
--   end process manchester_input;
   
end tb;