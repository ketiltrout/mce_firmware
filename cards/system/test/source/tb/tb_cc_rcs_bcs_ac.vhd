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
-- $Id: tb_cc_rcs_bcs_ac.vhd,v 1.86 2010/05/15 00:44:03 bburger Exp $
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
-- Revision 1.86  2010/05/15 00:44:03  bburger
-- BB:  Removed a couple of interface signals that conflict with CRC_ERROR on the Clock Card.
--
-- Revision 1.85  2010/05/14 22:27:13  bburger
-- BB:  Testbench for a bug that caused stale data to be returned in responses from cards that are not present
--
-- Revision 1.84  2010/03/15 14:31:47  bburger
-- BB: testing new tms_tdi and tdo commands
--
-- Revision 1.83  2010/03/06 11:02:02  bburger
-- BB: JTAG testing
--
-- Revision 1.82  2010/03/05 19:07:47  bburger
-- BB: JTAG testing
--
-- Revision 1.81  2010/02/26 09:20:10  bburger
-- BB: JTAG command testing.
--
-- Revision 1.80  2010/01/26 19:53:28  bburger
-- BB: AWG bug testing
--
-- Revision 1.79  2010/01/21 18:47:07  bburger
-- BB: internal_cmd_mode = 2
--
-- Revision 1.78  2010/01/18 20:39:38  bburger
-- BB: Changed "MLS" prefixes to "AWG" for "Abitrary Waveform Generator"
--
-- Revision 1.77  2010/01/13 20:32:46  bburger
-- BB: Added command declarations for MLS testing
--
-- Revision 1.76  2009/11/13 19:12:36  bburger
-- BB: Tests for finding the FSFB jumps seen at Caltech
--
-- Revision 1.75  2009/10/09 16:45:28  bburger
-- BB: address card heater_bias testing
--
-- Revision 1.74  2009/09/14 20:06:54  bburger
-- BB: BIAS_START_ADDR added
--
-- Revision 1.73  2009/08/21 22:26:21  bburger
-- BB: changed a wait period from 50 to 150 us
--
-- Revision 1.72  2009/07/11 00:18:53  bburger
-- BB: stratix iii development
--
-- Revision 1.71  2009/07/03 23:45:01  bburger
-- BB:  Pinout name changes.
--
-- Revision 1.70  2009/05/27 22:40:22  bburger
-- BB: Readout Card testing
--
-- Revision 1.69  2009/05/27 01:34:57  bburger
-- BB: Readout Card testing
--
-- Revision 1.68  2009/05/13 00:50:56  bburger
-- BB:  STOP commands again
--
-- Revision 1.67  2009/05/12 19:44:57  bburger
-- BB: STOP command testing.
--
-- Revision 1.66  2009/01/16 02:04:39  bburger
-- BB:  New test commands for column data from Readout Cards
--
-- Revision 1.65  2008/12/22 21:12:21  bburger
-- BB: For testing column data readout.
--
-- Revision 1.64  2008/10/17 00:37:20  bburger
-- BB:  cc_v0400000a
--
-- Revision 1.63  2008/07/15 17:49:50  bburger
-- BB: minor modifications for testing ST commands
--
-- Revision 1.62  2008/06/19 21:48:42  bburger
-- BB: Interface fix
--
-- Revision 1.61  2008/06/17 19:00:52  bburger
-- BB:  Added a couple of cases for testing const_val39
--
-- Revision 1.61  2008/06/12 21:45:07  bburger
-- BB:  Added a couple of cases for testing const_val39
--
-- Revision 1.60  2008/05/29 21:24:49  bburger
-- BB:  Modified for testing const_mode and const_val commands on the address/ fast biasing cards.
--
-- Revision 1.59  2008/02/27 17:53:20  bburger
-- BB: cc_v04000009
--
-- Revision 1.58  2008/02/03 09:54:06  bburger
-- BB:  Clock Card STOP command testing
--
-- Revision 1.57  2008/01/21 19:38:32  bburger
-- BB: testing sq2fb multiplexing firmware (Address Card)
--
-- Revision 1.56  2007/10/18 22:45:42  bburger
-- BB:  v04000005
--
-- Revision 1.55  2007/09/20 20:02:13  bburger
-- BB: cc_v04000002
--
-- Revision 1.54  2007/09/05 04:04:35  bburger
-- BB:  wbs_fb_data testing
--
-- Revision 1.53  2007/09/04 21:19:18  bburger
-- BB:  inputting unique values to readout card adc inputs
--
-- Revision 1.52  2007/08/30 18:35:13  bburger
-- BB:  cc_v04000000 (with ramp_value fix)
--
-- Revision 1.51  2007/08/28 23:37:17  bburger
-- BB: Added code for testing ramps and internal commands on the Clock Card.
--
-- Revision 1.50  2007/07/25 19:26:37  bburger
-- BB:  More tests
--
-- Revision 1.49  2007/03/22 21:14:57  bburger
-- Bryce:  ac_v02000003
--
-- Revision 1.48  2007/03/06 01:00:42  bburger
-- Bryce:  For fpga_temp testing
--
-- Revision 1.47  2007/02/19 22:01:35  mandana
-- added test case for rewrite of wbs_frame_data and capture_raw bugs in rc_v03000019 and on
--
-- Revision 1.44  2007/02/01 21:06:13  bburger
-- Bryce:  Added a delay between the two preamble words
--
-- Revision 1.43  2007/01/31 01:48:46  bburger
-- Bryce: added some more tiest cases
--
-- Revision 1.42  2007/01/24 01:36:58  bburger
-- Bryce:  More test cases
--
-- Revision 1.41  2006/12/22 22:05:44  bburger
-- Bryce:  Added a few more test cases
--
-- Revision 1.40  2006/12/06 02:18:26  bburger
-- Bryce:  Interim committal for v02000013d.  :)
--
-- Revision 1.39  2006/11/22 01:00:16  bburger
-- Bryce:  Interim commital
--
-- Revision 1.38  2006/11/03 01:06:00  bburger
-- Bryce:  Additional test cases.
--
-- Revision 1.37  2006/10/28 00:12:25  bburger
-- Bryce:  Added several more test cases
--
-- Revision 1.36  2006/10/24 17:17:59  bburger
-- Bryce:  Nothing new
--
-- Revision 1.35  2006/10/19 22:14:22  bburger
-- Bryce:  Added interface signals for BOX_ID to clock card
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
      -- Crystal Clock PLL input:
      inclk14           : in std_logic; -- Crystal Clock Input
      rst_n             : in std_logic;

      -- Manchester Clock PLL inputs:
      inclk15           : in std_logic;
      inclk1            : in std_logic;
      inclk5            : in std_logic;

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

      mosii             : in std_logic;
      sclki             : in std_logic;
      ccssi             : in std_logic;
      misoo             : out std_logic;
      sreqo             : out std_logic;

      -- SRAM bank 0 interface
      sram0_addr : out std_logic_vector(19 downto 0);
      sram0_data : inout std_logic_vector(15 downto 0);
      sram0_nbhe : out std_logic;
      sram0_nble : out std_logic;
      sram0_noe  : out std_logic;
      sram0_nwe  : out std_logic;
      sram0_nce1 : out std_logic;
      sram0_ce2  : out std_logic;

      -- SRAM bank 1 interface
      sram1_addr : out std_logic_vector(19 downto 0);
      sram1_data : inout std_logic_vector(15 downto 0);
      sram1_nbhe : out std_logic;
      sram1_nble : out std_logic;
      sram1_noe  : out std_logic;
      sram1_nwe  : out std_logic;
      sram1_nce1 : out std_logic;
      sram1_ce2  : out std_logic;

      -- miscellaneous ports:
      red_led           : out std_logic;
      ylw_led           : out std_logic;
      grn_led           : out std_logic;
      dip_sw3           : in std_logic;
      dip_sw4           : in std_logic;
      wdog              : out std_logic;
      slot_id           : in std_logic_vector(3 downto 0);
      array_id          : in std_logic_vector(2 downto 0);
      card_id           : inout std_logic;
      smb_clk           : out std_logic;
      smb_data          : inout std_logic;
      smb_nalert        : out std_logic;

      box_id_in         : in std_logic;
      box_id_out        : out std_logic;
      box_id_ena_n      : out std_logic;

      extend_n          : in std_logic;

      -- debug ports:
      mictor0_o         : out std_logic_vector(15 downto 0);
      mictor0clk_o      : out std_logic;
      mictor0_e         : in std_logic_vector(15 downto 0);
      mictor0clk_e      : in std_logic;
      mictor1_o         : out std_logic_vector(15 downto 0);
      mictor1clk_o      : out std_logic;
--      mictor1_e         : out std_logic_vector(15 downto 0);
--      mictor1clk_e      : out std_logic;

      rx                : in std_logic;
      tx                : out std_logic;

      -- interface to HOTLINK fibre receiver
      fibre_rx_data     : in std_logic_vector (7 downto 0);
      fibre_rx_rdy      : in std_logic;
      fibre_rx_rvs      : in std_logic;
      fibre_rx_status   : in std_logic;
      fibre_rx_sc_nd    : in std_logic;
      fibre_rx_clkr     : in std_logic;
      fibre_rx_refclk   : out std_logic;
      fibre_rx_a_nb     : out std_logic;
      fibre_rx_bisten   : out std_logic;
      fibre_rx_rf       : out std_logic;

      -- interface to hotlink fibre transmitter
      fibre_tx_clkw     : out std_logic;
      fibre_tx_data     : out std_logic_vector (7 downto 0);
      fibre_tx_ena      : out std_logic;
      fibre_tx_sc_nd    : out std_logic;
      fibre_tx_enn      : out std_logic;
      fibre_tx_bisten   : out std_logic;
      fibre_tx_foto     : out std_logic;

      -- JTAG
      fpga_tdo          : out std_logic; -- TDI (into JTAG chain)
      fpga_tck          : out std_logic; -- TCK
      fpga_tms          : out std_logic; -- TMS
      epc_tdo           : in std_logic;  -- TDO (out of JTAG chain)
      jtag_sel          : out std_logic; -- JTAG source: '0'=Header, '1'=FGPA
      nbb_jtag          : in std_logic;  -- JTAG source:  readback (jtag_sel)

      nreconf           : out std_logic;
      nepc_sel          : out std_logic
   );
   end component;

   component readout_card
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

         smb_clk         : out std_logic;
         smb_nalert      : out std_logic;
         smb_data        : inout std_logic;

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


   component readout_card_stratix_iii
      port(
         -- Global Interface
         dev_clr_n           : in std_logic;

         -- PLL Interface
         inclk           : in std_logic;
         inclk6          : in std_logic;
         inclk_ddr       : in std_logic;
         
         -- ADC Interface for Readout Card Rev. C 
         -- How do I instantiate and LVDS receiver?
         adc0_lvds : in std_logic; 
         adc1_lvds : in std_logic; 
         adc2_lvds : in std_logic; 
         adc3_lvds : in std_logic; 
         adc4_lvds : in std_logic; 
         adc5_lvds : in std_logic; 
         adc6_lvds : in std_logic; 
         adc7_lvds : in std_logic; 
         adc_fco   : in std_logic;
         adc_clk   : out std_logic; 
         adc_sclk    : out std_logic;
         adc_sdio    : inout std_logic; 
         adc_csb_n   : out std_logic; 
         adc_pdwn    : out std_logic;
         adc_dco   : in std_logic;

         -- DAC Interface
         dac_clr_n        : in std_logic; -- Implement this!!
         dac0_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac1_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac2_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac3_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac4_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac5_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac6_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac7_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_dfb_clk      : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
         
         -- Sa_bias and Offset_ctrl Interface
         dac_clk         : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
         dac_dat         : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
         bias_dac_ncs    : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
         offset_dac_ncs  : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
         
         -- LVDS interface:
         lvds_cmd        : in std_logic;
         lvds_sync       : in std_logic;
         lvds_spare      : in std_logic;
         lvds_txa        : out std_logic;
         lvds_txb        : out std_logic;

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

         -- LED Interface
         red_led         : out std_logic;
         ylw_led         : out std_logic;
         grn_led         : out std_logic;
         
         -- miscellaneous ports
         dip_sw0            : in std_logic;
         dip_sw1            : in std_logic;
         dip_sw2            : in std_logic;
         dip_sw3            : in std_logic;
         wdog             : out std_logic;
         rs232_tx        : out std_logic;
         rs232_rx        : in std_logic;
         eeprom_si       : in std_logic; -- Implement this
         eeprom_so       : out std_logic; -- Implement this
         eeprom_sck      : out std_logic; -- Implement this
         eeprom_cs_n     : out std_logic; -- Implement this
         crc_error_in    : in std_logic; -- Implement this
         critical_error  : in std_logic; -- Implement this
         extend_n        : in std_logic; -- Implement this   

         -- slot id interface  
         slot_id         : in std_logic_vector(3 downto 0);

         -- silicon_id/temperature interface
         card_id         : inout std_logic;
         
         -- fpga_thermo serial interface
         smb_clk         : out std_logic;
         smb_nalert      : out std_logic;
         smb_data        : inout std_logic;      

         -- DDR2 interface
         -- outputs:
         mem_addr       : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
         mem_ba         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_cas_n      : OUT STD_LOGIC;
         mem_cke        : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_clk        : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_clk_n      : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_cs_n       : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_dm         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_dq         : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         mem_dqs        : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_dqsn       : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_odt        : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_ras_n      : OUT STD_LOGIC;
         mem_we_n       : OUT STD_LOGIC;
         pnf            : OUT STD_LOGIC;
         pnf_per_byte   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         test_complete  : OUT STD_LOGIC;
         test_status    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         mictor_clk     : out std_logic -- Implement this!!!
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
      smb_nalert : out std_logic;

      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx   : in std_logic;
      tx   : out std_logic
   );
   end component;

   component addr_card
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
      dac_data0  : out std_logic_vector(13 downto 0);
      dac_data1  : out std_logic_vector(13 downto 0);
      dac_data2  : out std_logic_vector(13 downto 0);
      dac_data3  : out std_logic_vector(13 downto 0);
      dac_data4  : out std_logic_vector(13 downto 0);
      dac_data5  : out std_logic_vector(13 downto 0);
      dac_data6  : out std_logic_vector(13 downto 0);
      dac_data7  : out std_logic_vector(13 downto 0);
      dac_data8  : out std_logic_vector(13 downto 0);
      dac_data9  : out std_logic_vector(13 downto 0);
      dac_data10 : out std_logic_vector(13 downto 0);
      dac_clk    : out std_logic_vector(40 downto 0);

      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      card_id    : inout std_logic;
      smb_clk    : out std_logic;
      smb_nalert : out std_logic;
      smb_data   : inout std_logic;

      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(32 downto 1);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx         : in std_logic;
      tx         : out std_logic
   );
   end component;

   ------------------------------------------------
   -- Simulation Signals
   ------------------------------------------------
   type sim_states is (NOTHING, ROW_LEN, NUM_ROWS, STEP_PERIOD, READOUT_ROW_INDEX, DATA_MODE, RB_NUM_ROWS,
   STEP_MIN, STEP_SIZE, STEP_MAX, STEP_PARAM_ID, STEP_CARD_ADDR, STEP_MODE, NUM_ROWS_TO_READ, DATA_RATE, RET_DAT_S, INTERNAL_CMD_MODE, RET_DAT);
   signal present_sim_state : sim_states;

   signal clk          : std_logic := '0';
   signal mem_clk      : std_logic := '0';
   signal comm_clk     : std_logic := '0';
   signal fibre_clk    : std_logic := '0';
   signal lvds_clk_i   : std_logic := '0';
   signal sync_en      : std_logic_vector(1 downto 0) := "00";

   constant clk_period          : TIME := 40 ns;    -- 50Mhz clock
   constant sync_clk_period     : TIME := 39 ns;
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
   signal address_id           : std_logic_vector(31 downto 0) := X"00000000";

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
   constant rc1_gainp2_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP2_ADDR;
   constant rc1_gainp3_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP3_ADDR;
   constant rc1_gainp4_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP4_ADDR;
   constant rc1_gainp5_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP5_ADDR;
   constant rc1_gainp6_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP6_ADDR;
   constant rc1_gainp7_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINP7_ADDR;
   constant rc1_gaini0_cmd          : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & GAINI0_ADDR;
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
   constant rc1_fpga_temp_cmd       : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1    & x"00" & FPGA_TEMP_ADDR;
   constant rc1_readout_priority_cmd  : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1  & x"00" & READOUT_PRIORITY_ADDR;
   constant rc1_readout_col_index_cmd : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1  & x"00" & READOUT_COL_INDEX_ADDR;
   constant rc1_readout_row_index_cmd : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1  & x"00" & READOUT_ROW_INDEX_ADDR;
   constant rc1_i_clamp_val_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1  & x"00" & I_CLAMP_VAL_ADDR;
 
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
--   constant rc4_row_dly_cmd         : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_4    & x"00" & ROW_DLY_ADDR;

   constant all_scratch_cmd          : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS        & x"00" & SCRATCH_ADDR;
   constant cc_scratch_cmd          : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & SCRATCH_ADDR;
   constant bc1_scratch_cmd          : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1        & x"00" & SCRATCH_ADDR;
   constant bc2_scratch_cmd          : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_2        & x"00" & SCRATCH_ADDR;
   constant bc3_scratch_cmd          : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_3        & x"00" & SCRATCH_ADDR;
   constant ac_scratch_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD        & x"00" & SCRATCH_ADDR;

   constant cc_cards_present_cmd    : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CARDS_PRESENT_ADDR;
   constant cc_rcs_to_report_cmd    : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CARDS_TO_REPORT_ADDR;
   constant cc_stop_delay_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & STOP_DLY_ADDR;
   constant cc_row_order_cmd        : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & ROW_ORDER_ADDR;
   constant cc_fpga_temp_cmd        : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & FPGA_TEMP_ADDR;
   constant cc_fw_rev_cmd           : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & FW_REV_ADDR;
   constant cc_config_fac_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CONFIG_FAC_ADDR;
   constant cc_config_app_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CONFIG_APP_ADDR;
   constant cc_row_len_cmd          : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & ROW_LEN_ADDR;
   constant cc_num_rows_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & NUM_ROWS_ADDR;
   constant cc_ret_dat_s_cmd        : std_logic_vector(31 downto 0) := X"00020053";  -- card id=0, ret_dat_s command
   signal   ret_dat_s_stop          : std_logic_vector(31 downto 0) := X"00000005";
   constant cc_led_cmd              : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & LED_ADDR;
   constant cc_array_id_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & ARRAY_ID_ADDR;
   constant cc_use_dv_cmd           : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & USE_DV_ADDR;
   constant cc_use_sync_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & USE_SYNC_ADDR;
   constant cc_data_rate_cmd        : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & DATA_RATE_ADDR;
   constant cc_select_clk_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & SELECT_CLK_ADDR;
   constant cc_mce_bclr_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & MCE_BCLR_ADDR;
   constant cc_cc_bclr_cmd          : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CC_BCLR_ADDR;

   constant cc_box_id_cmd           : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & BOX_ID_ADDR;
   constant cc_tes_tgl_en_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_EN_ADDR;
   constant cc_tes_tgl_max_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_MAX_ADDR;
   constant cc_tes_tgl_min_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_MIN_ADDR;
   constant cc_tes_tgl_rate_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TES_TGL_RATE_ADDR;
   constant cc_int_cmd_en_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & INT_CMD_EN_ADDR;
   constant cc_crc_err_en_cmd       : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CRC_ERR_EN_ADDR;

   constant cc_num_rows_to_read_cmd : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & NUM_ROWS_REPORTED_ADDR;
   constant cc_num_cols_to_read_cmd : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & NUM_COLS_REPORTED_ADDR;
   constant cc_internal_cmd_mode_cmd : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD       & x"00" & INTERNAL_CMD_MODE_ADDR;
   constant cc_step_period_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RAMP_STEP_PERIOD_ADDR;
   constant cc_step_minimum_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RAMP_MIN_VAL_ADDR;
   constant cc_step_size_cmd        : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RAMP_STEP_SIZE_ADDR;
   constant cc_step_maximum_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RAMP_MAX_VAL_ADDR;
   constant cc_step_param_id_cmd    : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RAMP_PARAM_ID_ADDR;
   constant cc_step_card_addr_cmd   : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RAMP_CARD_ADDR_ADDR;
   constant cc_step_data_num_cmd    : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RAMP_STEP_DATA_NUM_ADDR;
   constant cc_run_id_cmd           : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & RUN_ID_ADDR;
   constant cc_user_writable_cmd    : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & USER_WRITABLE_ADDR;
   constant cc_cards_to_report      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & CARDS_TO_REPORT_ADDR;
   constant cc_num_rows_reported_cmd : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD       & x"00" & NUM_ROWS_REPORTED_ADDR;
   constant cc_num_cols_reported_cmd : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD       & x"00" & NUM_COLS_REPORTED_ADDR;

   constant cc_awg_sequence_len_cmd : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & AWG_SEQUENCE_LEN_ADDR;
   constant cc_awg_data_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & AWG_DATA_ADDR;
   constant cc_awg_addr_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & AWG_ADDR_ADDR;

   constant cc_jtag0_cmd            : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & JTAG0_ADDR;
   constant cc_jtag1_cmd            : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & JTAG1_ADDR;
   constant cc_jtag2_cmd            : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & JTAG2_ADDR;
   constant cc_tms_tdi_cmd          : std_logic_vector(31 downto 0) := x"00020050";
   constant cc_tdo_cmd              : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TDO_ADDR;
   constant cc_tdo_sample_dly_cmd   : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TDO_SAMPLE_DLY_ADDR;
   constant cc_tck_half_period_cmd  : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD        & x"00" & TCK_HALF_PERIOD_ADDR;
   signal   tms_tdi_data            : std_logic_vector(31 downto 0) := "0000" & "0000101000" & "10101000" & "1010101010";

   constant psu_brst_mce_cmd        : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & BRST_MCE_ADDR;
   constant psu_cycle_pow_cmd       : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & CYCLE_POW_ADDR;
   constant psu_cut_pow_cmd         : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & CUT_POW_ADDR;
   constant psu_status_cmd          : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & PSC_STATUS_ADDR;
   constant psu_led_cmd             : std_logic_vector(31 downto 0) := x"00" & POWER_SUPPLY_CARD & x"00" & LED_ADDR;

   constant bcs_flux_fdbck_cmd      : std_logic_vector(31 downto 0) := x"00" & ALL_BIAS_CARDS    & x"00" & FLUX_FB_ADDR;
   constant bcs_bias_cmd            : std_logic_vector(31 downto 0) := x"00" & ALL_BIAS_CARDS    & x"00" & BIAS_ADDR;

   constant ac_fb_col0_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL0_ADDR;
   constant ac_fb_col1_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL1_ADDR;
   constant ac_fb_col2_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL2_ADDR;
   constant ac_fb_col3_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL3_ADDR;
   constant ac_fb_col4_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL4_ADDR;
   constant ac_fb_col5_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL5_ADDR;
   constant ac_fb_col6_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL6_ADDR;
   constant ac_fb_col7_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL7_ADDR;
   constant ac_fb_col8_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL8_ADDR;
   constant ac_fb_col9_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL9_ADDR;
   constant ac_fb_col10_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL10_ADDR;
   constant ac_fb_col11_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL11_ADDR;
   constant ac_fb_col12_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL12_ADDR;
   constant ac_fb_col13_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL13_ADDR;
   constant ac_fb_col14_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL14_ADDR;
   constant ac_fb_col15_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL15_ADDR;
   constant ac_fb_col16_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL16_ADDR;
   constant ac_fb_col17_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL17_ADDR;
   constant ac_fb_col18_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL18_ADDR;
   constant ac_fb_col19_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL19_ADDR;
   constant ac_fb_col20_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL20_ADDR;
   constant ac_fb_col21_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL21_ADDR;
   constant ac_fb_col22_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL22_ADDR;
   constant ac_fb_col23_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL23_ADDR;
   constant ac_fb_col24_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL24_ADDR;
   constant ac_fb_col25_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL25_ADDR;
   constant ac_fb_col26_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL26_ADDR;
   constant ac_fb_col27_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL27_ADDR;
   constant ac_fb_col28_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL28_ADDR;
   constant ac_fb_col29_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL29_ADDR;
   constant ac_fb_col30_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL30_ADDR;
   constant ac_fb_col31_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL31_ADDR;
   constant ac_fb_col32_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL32_ADDR;
   constant ac_fb_col33_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL33_ADDR;
   constant ac_fb_col34_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL34_ADDR;
   constant ac_fb_col35_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL35_ADDR;
   constant ac_fb_col36_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL36_ADDR;
   constant ac_fb_col37_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL37_ADDR;
   constant ac_fb_col38_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL38_ADDR;
   constant ac_fb_col39_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL39_ADDR;
   constant ac_fb_col40_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & FB_COL40_ADDR;
   constant ac_led_cmd              : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & LED_ADDR;
   constant ac_on_bias_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ON_BIAS_ADDR;
   constant ac_off_bias_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & OFF_BIAS_ADDR;
   constant ac_row_order_cmd        : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ROW_ORDER_ADDR;
   constant ac_enbl_mux_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ENBL_MUX_ADDR;
   constant ac_row_dly_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ROW_DLY_ADDR;
   constant ac_row_len_cmd          : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & ROW_LEN_ADDR;
   constant ac_num_rows_cmd         : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & NUM_ROWS_ADDR;
   constant ac_const_mode_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & CONST_MODE_ADDR;
   constant ac_const_val_cmd        : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & CONST_VAL_ADDR;
   constant ac_const_val39_cmd      : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & CONST_VAL39_ADDR;
   constant ac_bias_start_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & BIAS_START_ADDR;
   constant ac_heater_bias_cmd      : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & HEATER_BIAS_ADDR;
   constant ac_heater_bias_len_cmd  : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD      & x"00" & HEATER_BIAS_LEN_ADDR;

   constant bc1_flux_fb_cmd         : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1       & x"00" & FLUX_FB_ADDR;
   constant bc1_bias_cmd            : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1       & x"00" & BIAS_ADDR;
   constant bc1_row_len_cmd         : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1       & x"00" & ROW_LEN_ADDR;
   constant bc1_num_rows_cmd        : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1       & x"00" & NUM_ROWS_ADDR;
   constant bc2_led_cmd             : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_2       & x"00" & LED_ADDR;

   constant all_led_cmd             : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & LED_ADDR;
   constant sys_num_rows_reported_cmd : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS  & x"00" & NUM_ROWS_REPORTED_ADDR;
   constant sys_num_cols_reported_cmd : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS  & x"00" & NUM_COLS_REPORTED_ADDR;
   constant sys_row_len_cmd         : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & ROW_LEN_ADDR;
   constant sys_num_rows_cmd        : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & NUM_ROWS_ADDR;
   constant all_sample_delay_cmd    : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & SAMPLE_DLY_ADDR;
   constant all_sample_num_cmd      : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & SAMPLE_NUM_ADDR;
   constant all_fb_dly_cmd          : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & FB_DLY_ADDR;
   constant all_flx_lp_init_cmd     : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & FLX_LP_INIT_ADDR;
--   constant all_row_dly_cmd         : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS    & x"00" & ROW_DLY_ADDR;
   constant all_num_rows_reported_cmd : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS       & x"00" & NUM_ROWS_REPORTED_ADDR;
   constant all_num_cols_reported_cmd : std_logic_vector(31 downto 0) := x"00" & ALL_FPGA_CARDS       & x"00" & NUM_COLS_REPORTED_ADDR;

   constant data_block              : positive := 58;

   signal checksum                  : std_logic_vector(31 downto 0) := X"00000000";
   signal command                   : std_logic_vector(31 downto 0);
   signal data_valid                : std_logic_vector(31 downto 0); -- used to be set to constant X"00000028"
   signal data                      : std_logic_vector(31 downto 0) := X"00000001";--integer := 1;
   signal data_constant             : std_logic := '0';
   ------------------------------------------------
   -- Counter Signals
   ------------------------------------------------
   signal ctr_ena         : std_logic := '1';
   signal ctr_load        : std_logic := '0';
   signal ctr_count_i     : integer := 0;
   signal ctr_count_o     : integer;
   signal ctr_count_slv_o : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);

   signal skip_byte       : std_logic := '0';
   signal add_byte        : std_logic := '0';
   signal wrong_checksum  : std_logic := '0';

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
   signal adc_clk      : std_logic := '0';
   signal fco_clk      : std_logic := '0';
   signal inclk15    : std_logic := '1';
   signal inclk1    : std_logic := '1';
   signal inclk5    : std_logic := '1';
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
   signal cc_mictor_e    : std_logic_vector(15 downto 0) := (others => '0');
   signal cc_mictorclk_e : std_logic := '0';
   signal cc_rs232_rx    : std_logic := '0';
   signal cc_rs232_tx    : std_logic;

   -- interface to HOTLINK fibre receiver
   signal fibre_rx_data      : std_logic_vector (7 downto 0) := (others => '0');
   signal fibre_rx_nrdy       : std_logic := '1';
   signal fibre_rx_rvs       : std_logic := '0';
   signal fibre_rx_status    : std_logic := '1';
   signal fibre_rx_sc_nd     : std_logic := '0';
   signal fibre_rx_ckr       : std_logic := '0';

--      fibre_rx_sc_nd  <= '0';
--      fibre_rx_status <= '1';
--      fibre_rx_rvs    <= '0';

   -- interface to hotlink fibre transmitter
   signal fibre_tx_data      : std_logic_vector (7 downto 0);
   signal fibre_tx_ena       : std_logic;
   signal fibre_tx_sc_nd     : std_logic;

   signal jtag_loopback      : std_logic := '0';
   signal jtag_tck           : std_logic;
   signal jtag_tms           : std_logic;
   signal jtag_sel           : std_logic;
   signal jtag_ena           : std_logic;

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

   signal count_new   : std_logic_vector(10 downto 0) := "00000000001";
   signal count       : std_logic_vector(10 downto 0) := "00000000000";

begin
   bclr_n <= not bclr;
   lvds_sync <=
      cc_lvds_sync when sync_en = "00" else
      '0'          when sync_en = "01" else
      noisy_sync   when sync_en = "10";

   ------------------------------------------------
   -- Create test bench clock
   -------------------------------------------------

--   i_counter : counter
----   generic map(
----      MAX         : integer := 255;
----      STEP_SIZE   : integer := 1;
----      WRAP_AROUND : std_logic := '1';
----      UP_COUNTER  : std_logic := '1'
----   );
--   port map(
--      clk_i   => inclk,
--      rst_i   => rst_n,
--      ena_i   => ctr_ena,
--      load_i  => ctr_load,
--      count_i => ctr_count_i,
--      count_o => ctr_count_o
--   );

   count_new <= count + 1;
   process(adc_clk, rst)
   begin
      if(rst = '1') then
         count <= "00000000000";
      elsif(adc_clk'event) then
         count <= count_new;
      end if;
   end process;

   rst          <= not rst_n;
   -- Clock generation
   adc_clk      <= not adc_clk      after clk_period/28;
   fco_clk      <= not fco_clk      after clk_period/4;   
   inclk        <= not inclk        after clk_period/2;
   
   inclk15      <= not inclk15      after sync_clk_period/2;
   inclk1       <= not inclk1       after sync_clk_period/2;
   inclk5       <= not inclk5       after sync_clk_period/2;

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
   rc1_adc1_dat <= "00000010000000"; -- 128  -- Bryce
   rc1_adc2_dat <= "00000000000000"; -- "001" & count;  --
   rc1_adc3_dat <= "00000000000000"; -- "010" & count;  --
   rc1_adc4_dat <= "00000000000000"; -- "011" & count;  --
   rc1_adc5_dat <= "00000000000000"; -- "100" & count;  --
   rc1_adc6_dat <= "00000000000000"; -- "101" & count;  --
   rc1_adc7_dat <= "00000000000000"; -- "110" & count;  --
   rc1_adc8_dat <= "00000000000000"; -- "111" & count;  --
   rc2_adc1_rdy <= inclk;
   rc2_adc2_rdy <= inclk;
   rc2_adc3_rdy <= inclk;
   rc2_adc4_rdy <= inclk;
   rc2_adc5_rdy <= inclk;
   rc2_adc6_rdy <= inclk;
   rc2_adc7_rdy <= inclk;
   rc2_adc8_rdy <= inclk;
--   rc2_adc1_dat <= ctr_count_slv_o;
--   rc2_adc2_dat <= ctr_count_slv_o;
--   rc2_adc3_dat <= ctr_count_slv_o;
--   rc2_adc4_dat <= ctr_count_slv_o;
--   rc2_adc5_dat <= ctr_count_slv_o;
--   rc2_adc6_dat <= ctr_count_slv_o;
--   rc2_adc7_dat <= ctr_count_slv_o;
--   rc2_adc8_dat <= ctr_count_slv_o;
   rc3_adc1_rdy <= inclk;
   rc3_adc2_rdy <= inclk;
   rc3_adc3_rdy <= inclk;
   rc3_adc4_rdy <= inclk;
   rc3_adc5_rdy <= inclk;
   rc3_adc6_rdy <= inclk;
   rc3_adc7_rdy <= inclk;
   rc3_adc8_rdy <= inclk;
--   rc3_adc1_dat <= ctr_count_slv_o;
--   rc3_adc2_dat <= ctr_count_slv_o;
--   rc3_adc3_dat <= ctr_count_slv_o;
--   rc3_adc4_dat <= ctr_count_slv_o;
--   rc3_adc5_dat <= ctr_count_slv_o;
--   rc3_adc6_dat <= ctr_count_slv_o;
--   rc3_adc7_dat <= ctr_count_slv_o;
--   rc3_adc8_dat <= ctr_count_slv_o;
   rc3_adc1_rdy <= inclk;
   rc4_adc2_rdy <= inclk;
   rc4_adc3_rdy <= inclk;
   rc4_adc4_rdy <= inclk;
   rc4_adc5_rdy <= inclk;
   rc4_adc6_rdy <= inclk;
   rc4_adc7_rdy <= inclk;
   rc4_adc8_rdy <= inclk;
--   rc4_adc1_dat <= ctr_count_slv_o;
--   rc4_adc2_dat <= ctr_count_slv_o;
--   rc4_adc3_dat <= ctr_count_slv_o;
--   rc4_adc4_dat <= ctr_count_slv_o;
--   rc4_adc5_dat <= ctr_count_slv_o;
--   rc4_adc6_dat <= ctr_count_slv_o;
--   rc4_adc7_dat <= ctr_count_slv_o;
--   rc4_adc8_dat <= ctr_count_slv_o;

   i_clk_card : clk_card
      port map
      (
         -- PLL input:
         inclk14          => inclk_conditioned,
         rst_n            => rst_n,

         -- Manchester Clock PLL inputs:
         inclk1           => inclk1,
         inclk5           => inclk5,
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
         array_id         => "001",
         box_id_in        => '0',
         box_id_out       => open,
         box_id_ena_n     => open,

         extend_n         => '0',

         card_id           => open,
         smb_clk           => open,
         smb_data          => open,
         smb_nalert        => open,

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
         fibre_rx_rdy     => fibre_rx_nrdy,
         fibre_rx_rvs     => fibre_rx_rvs,
         fibre_rx_status  => fibre_rx_status,
         fibre_rx_sc_nd   => fibre_rx_sc_nd,
         fibre_rx_clkr    => fibre_rx_ckr,

         -- interface to hotlink fibre transmitter
         fibre_tx_clkw    => open,
         fibre_tx_data    => fibre_tx_data,
         fibre_tx_ena     => fibre_tx_ena,
         fibre_tx_sc_nd   => fibre_tx_sc_nd,
   
         -- JTAG
         fpga_tdo         => open, 
         fpga_tck         => jtag_tck,
         fpga_tms         => jtag_tms,
         epc_tdo          => jtag_loopback,  -- Clock
         jtag_sel         => jtag_sel, 
         nbb_jtag         => jtag_sel,  

         nreconf          => nreconf,
         nepc_sel         => nepc_sel
      );

--   i_readout_card4: readout_card
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
--         smb_clk        => open,
--         smb_nalert     => open,
--         smb_data       => open,
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
--         smb_clk        => open,
--         smb_nalert     => open,
--         smb_data       => open,
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
--         smb_clk        => open,
--         smb_nalert     => open,
--         smb_data       => open,
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

         smb_clk        => open,
         smb_nalert     => open,
         smb_data       => open,

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
--   i_readout_card1 : readout_card_stratix_iii
--      port map(
--         dev_clr_n      => rst_n, --: in std_logic;
--         inclk          => lvds_clk, --: in std_logic;
--         inclk6         => fco_clk,
--         inclk_ddr      => '0', --: in std_logic;
--         adc0_lvds    => rc1_adc1_dat(0), --: in std_logic; 
--         adc1_lvds    => rc1_adc2_dat(1), --: in std_logic; 
--         adc2_lvds    => rc1_adc3_dat(2), --: in std_logic; 
--         adc3_lvds    => rc1_adc4_dat(3), --: in std_logic; 
--         adc4_lvds    => rc1_adc5_dat(4), --: in std_logic; 
--         adc5_lvds    => rc1_adc6_dat(5), --: in std_logic; 
--         adc6_lvds    => rc1_adc7_dat(6), --: in std_logic; 
--         adc7_lvds    => rc1_adc8_dat(7), --: in std_logic; 
--         adc_fco      => fco_clk, --: in std_logic;
--         adc_clk      => open, --: out std_logic; 
--         adc_sclk       => open, --: out std_logic;
--         adc_sdio       => open, --: inout std_logic; 
--         adc_csb_n      => open, --: out std_logic; 
--         adc_pdwn       => open, --: out std_logic;
--         adc_dco      => '0', --: in std_logic;
--         dac_clr_n      => '1', --: out std_logic; -- Implement this!!
--         dac0_dfb_dat   => rc1_dac_FB1_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac1_dfb_dat   => rc1_dac_FB2_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac2_dfb_dat   => rc1_dac_FB3_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac3_dfb_dat   => rc1_dac_FB4_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac4_dfb_dat   => rc1_dac_FB5_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac5_dfb_dat   => rc1_dac_FB6_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac6_dfb_dat   => rc1_dac_FB7_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac7_dfb_dat   => rc1_dac_FB8_dat, --: out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
--         dac_dfb_clk    => rc1_dac_FB_clk, --: out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
--         dac_clk        => rc1_dac_clk, --: out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
--         dac_dat        => rc1_dac_dat, --: out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
--         bias_dac_ncs   => rc1_bias_dac_ncs, --: out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
--         offset_dac_ncs => rc1_offset_dac_ncs, --: out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
--         lvds_cmd       => lvds_cmd, --: in std_logic;
--         lvds_sync      => lvds_sync, --: in std_logic;
--         lvds_spare     => lvds_spare, --: in std_logic;
--         lvds_txa       => rc1_lvds_txa, --: out std_logic;
--         lvds_txb       => rc1_lvds_txb, --: out std_logic;
--         ttl_dir1       => rc1_ttl_dir1, --: out std_logic;
--         ttl_in1        => bclr_n, --: in std_logic;
--         ttl_out1       => open, --: out std_logic;
--         ttl_dir2       => rc1_ttl_dir2, --: out std_logic;
--         ttl_in2        => rc1_ttl_in2, --: in std_logic;
--         ttl_out2       => open, --: out std_logic;
--         ttl_dir3       => rc1_ttl_dir3, --: out std_logic;
--         ttl_in3        => rc1_ttl_in3, --: in std_logic;
--         ttl_out3       => open, --: out std_logic;
--         red_led        => rc1_red_led, --: out std_logic;
--         ylw_led        => rc1_ylw_led, --: out std_logic;
--         grn_led        => rc1_grn_led, --: out std_logic;
--         dip_sw0           => '0',
--         dip_sw1           => '0',
--         dip_sw2           => rc1_dip_sw3, --: in std_logic;
--         dip_sw3           => rc1_dip_sw4, --: in std_logic;
--         wdog           => rc1_wdog, --: out std_logic;
--         rs232_tx       => open, --: out std_logic;
--         rs232_rx       => '0', --: in std_logic;
--         eeprom_si      => '0', --: in std_logic; -- Implement this
--         eeprom_so      => open, --: out std_logic; -- Implement this
--         eeprom_sck     => open, --: out std_logic; -- Implement this
--         eeprom_cs_n    => open, --: out std_logic; -- Implement this
--         crc_error_in   => '0', --: in std_logic; -- Implement this
--         critical_error => '0', --: in std_logic; -- Implement this
--         extend_n       => '1', --: in std_logic; -- Implement this   
--         slot_id        => rc1_slot_id,
--         card_id        => open, --: inout std_logic;
--         smb_clk        => open, --: out std_logic;
--         smb_nalert     => open, --: in std_logic;
--         smb_data       => open, --: inout std_logic;      
--
--         mem_odt        => open, --: OUT std_logic_vector (0 DOWNTO 0);
--         mem_cke        => open, --: OUT std_logic_vector (0 DOWNTO 0);
--         mem_clk        => open, --: INOUT std_logic_vector (0 DOWNTO 0);
--         mem_clk_n      => open, --: INOUT std_logic_vector (0 DOWNTO 0);
--         mem_cs_n       => open, --: OUT std_logic_vector (0 DOWNTO 0);
--         mem_cas_n      => open, --: OUT std_logic;
--         mem_ras_n      => open, --: OUT std_logic;
--         mem_we_n       => open, --: OUT std_logic;
--         mem_addr          => open, --: OUT std_logic_vector (12 DOWNTO 0);
--         mem_ba         => open, --: OUT std_logic_vector (1 DOWNTO 0);
--         mem_dq         => open, --: INOUT std_logic_vector (15 DOWNTO 0);
----         ddr_ldm        => open, --: OUT std_logic_vector (0 DOWNTO 0);
----         ddr_udm        => open, --: OUT std_logic_vector (0 DOWNTO 0);
--         mem_dm         => open,
--         mem_dqs        => open, --: INOUT std_logic_vector (1 DOWNTO 0);
--         mem_dqsn       => open, --: INOUT std_logic_vector (1 DOWNTO 0);
--         mictor_clk     => open, --: out std_logic; -- Implement this!!!
--         pnf            => open, --: OUT std_logic;
--         pnf_per_byte   => open, --: OUT std_logic_vector (7 DOWNTO 0);
--         test_complete  => open, --: OUT std_logic;
--         test_status    => open --: OUT std_logic_vector (7 DOWNTO 0)
--      );  
--
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
--         smb_nalert      => open,
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
--         smb_nalert       => open,
--
--         -- debug ports:
--         test          => bc2_test,
--         mictor        => bc2_mictor,
--         mictorclk     => bc2_mictorclk,
--         rx            => bc2_rs232_rx,
--         tx            => bc2_rs232_tx
--      );
--
--   i_bias_card1: bias_card
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
--         lvds_txa      => lvds_reply_bc1_a,
--         lvds_txb      => lvds_reply_bc1_b,
--
--         -- TTL interface:
--         ttl_nrx1      => bclr_n,
--         ttl_tx1       => open,
--         ttl_txena1    => bc1_ttl_txena1,
--
--         ttl_nrx2      => bc1_ttl_nrx2,
--         ttl_tx2       => open,
--         ttl_txena2    => bc1_ttl_txena2,
--
--         ttl_nrx3      => bc1_ttl_nrx3,
--         ttl_tx3       => open,
--         ttl_txena3    => bc1_ttl_txena3,
--
--         -- eeprom ice:nterface:
--         eeprom_si     => bc1_eeprom_si,
--         eeprom_so     => bc1_eeprom_so,
--         eeprom_sck    => bc1_eeprom_sck,
--         eeprom_cs     => bc1_eeprom_cs,
--
--         -- dac interface:
--         dac_ncs       => bc1_dac_ncs,
--         dac_sclk      => bc1_dac_sclk,
--         dac_data      => bc1_dac_data,
--         lvds_dac_ncs  => bc1_lvds_dac_ncs,
--         lvds_dac_sclk => bc1_lvds_dac_sclk,
--         lvds_dac_data => bc1_lvds_dac_data,
--         dac_nclr      => bc1_dac_nclr,
--
--         -- miscellaneous ports:
--         red_led       => bc1_red_led,
--         ylw_led       => bc1_ylw_led,
--         grn_led       => bc1_grn_led,
--         dip_sw3       => bc1_dip_sw3,
--         dip_sw4       => bc1_dip_sw4,
--         wdog          => bc1_wdog,
--         slot_id       => bc1_slot_id,
--         smb_nalert       => open,
--
--         -- debug ports:
--         test          => bc1_test,
--         mictor        => bc1_mictor,
--         mictorclk     => bc1_mictorclk,
--         rx            => bc1_rs232_rx,
--         tx            => bc1_rs232_tx
--      );
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
--         smb_nalert       => open,
--
--         -- debug ports:
--         test             => ac_test,
--         mictor           => ac_mictor,
--         mictorclk        => ac_mictorclk,
--         rx               => ac_rs232_rx,
--         tx               => ac_rs232_tx
--      );

   ------------------------------------------------
   -- Create test bench stimuli
   -------------------------------------------------

   stimuli : process

--   procedure do_reset is
--   begin
--      -- setup the hotlink receiver to receive the special character
--      fibre_rx_sc_nd  <= '1';
--      fibre_rx_status <= '1';
--      fibre_rx_rvs    <= '0';
--
--      -- special case for the reset character
--      fibre_rx_nrdy    <= '0';  -- data not ready (active low)
--      fibre_rx_data   <= SPEC_CHAR_RESET;
--
--      wait for fibre_clkr_prd * 0.4;
--
--      -- set up hotlink receiver signals
--      fibre_rx_sc_nd  <= '0';
--      fibre_rx_status <= '1';
--      fibre_rx_rvs    <= '0';
--
--      -- set default values for input
--      fibre_rx_nrdy    <= '0';  -- data not ready (active low)
--      fibre_rx_data   <= x"00";
--
--      wait for fibre_clkr_prd * 0.6;
--
--
--
--      rst_n <= '0';
--      wait for clk_period*5 ;
--      rst_n <= '1';
--      wait for clk_period*5 ;
--      assert false report " Resetting the DUT." severity NOTE;
--
--   end do_reset;

   procedure do_bclr is
   begin
      -- setup the hotlink receiver to receive the special character
      fibre_rx_sc_nd  <= '1';
      fibre_rx_status <= '1';
      fibre_rx_rvs    <= '0';

      -- special case for the reset character
      fibre_rx_nrdy    <= '0';  -- data not ready (active low)
      fibre_rx_data   <= SPEC_CHAR_RESET;

      wait for fibre_clkr_prd;

      -- set default values for input
      fibre_rx_nrdy    <= '1';  -- data not ready (active low)
      fibre_rx_sc_nd  <= '0';
      fibre_rx_data   <= x"00";



      assert false report " BClr." severity NOTE;
   end do_bclr;

   procedure do_push_button_reset is
   begin
      rst_n <= '0';
      wait for clk_period*5 ;
      rst_n <= '1';
      wait for clk_period*5 ;
      assert false report " Push Button Reset." severity NOTE;
   end do_push_button_reset;
   --------------------------------------------------

   procedure load_preamble is
   begin

   for I in 0 to 3 loop
      fibre_rx_nrdy    <= '1';  -- data not ready (active low)
      fibre_rx_data  <= preamble1;
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;

   fibre_rx_nrdy <= '1';
   wait for pci_dsp_dly;

   for I in 0 to 3 loop
      fibre_rx_nrdy    <= '1';  -- data not ready (active low)
      fibre_rx_data  <= preamble2;
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;

   fibre_rx_nrdy <= '1';
   wait for pci_dsp_dly;

   assert false report "preamble OK" severity NOTE;
   end load_preamble;

   ---------------------------------------------------------

   procedure load_command is
   begin
      checksum  <= command;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= command(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= command(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= command(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= command(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;


      assert false report "command code loaded" severity NOTE;
      fibre_rx_nrdy <= '1';
      wait for pci_dsp_dly;

      -- load up address_id
      checksum <= checksum XOR address_id;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= address_id(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= address_id(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= address_id(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data   <= address_id(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      assert false report "address id loaded" severity NOTE;
      fibre_rx_nrdy <= '1';
      wait for pci_dsp_dly;

      -- load up data valid
      checksum <= checksum XOR data_valid;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data <= data_valid(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data <= data_valid(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data <= data_valid(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;


      fibre_rx_nrdy   <= '1';
      fibre_rx_data <= data_valid(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      assert false report "data valid loaded" severity NOTE;
      fibre_rx_nrdy <= '1';
      wait for pci_dsp_dly;

      -- load up data block
      -- first load valid data
      for I in 0 to (conv_integer(data_valid)-1) loop
      --for I in 0 to (data_valid-1) loop

         fibre_rx_nrdy   <= '1';

         fibre_rx_data <= data(7 downto 0);
         checksum (7 downto 0) <= checksum (7 downto 0) XOR data(7 downto 0);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy   <= '1';

         fibre_rx_data <= data(15 downto 8);
         checksum (15 downto 8) <= checksum (15 downto 8) XOR data(15 downto 8);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy   <= '1';

         fibre_rx_data <= data(23 downto 16);
         checksum (23 downto 16) <= checksum (23 downto 16) XOR data(23 downto 16);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy   <= '1';

         fibre_rx_data <= data(31 downto 24);
         checksum (31 downto 24) <= checksum (31 downto 24) XOR data(31 downto 24);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';

         -- bryce
         case address_id is
            when cc_ret_dat_s_cmd => data <= ret_dat_s_stop;
            when rc1_ret_dat_cmd  => data <= (others => '0');
            when rc2_ret_dat_cmd  => data <= (others => '0');
            when rc3_ret_dat_cmd  => data <= (others => '0');
            when rc4_ret_dat_cmd  => data <= (others => '0');
            when rcs_ret_dat_cmd  => data <= (others => '0');
            --when cc_tms_tdi_cmd   => data <= x"00000002"; --"0000" & "0000101000" & "10101000" & "1010101010"
            when cc_tms_tdi_cmd   => data <= "01100110011001100110011001100110";
            --when ac_const_val_cmd => data <= data;
--            when others           => data <= data + 1;
            when others           => data <= data;
         end case;
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy <= '1';
         wait for pci_dsp_dly;
      end loop;

      for J in (conv_integer(data_valid)) to data_block-1 loop
         fibre_rx_nrdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         fibre_rx_nrdy <= '1';
         wait for pci_dsp_dly;
      end loop;

      assert false report "data words loaded to memory...." severity NOTE;

   end load_command;

   ------------------------------------------------------
   procedure load_checksum is

      begin

      ------------------------------------------------------------------------------------------
      -- This logic is for testing the ability of fibre_rx to recover from errors over the fibre
      ------------------------------------------------------------------------------------------
--      if(skip_byte = '0') then
--         fibre_rx_nrdy   <= '1';
--         fibre_rx_data <= data_valid(31 downto 24);
--         wait for fibre_clkr_prd * 0.4;
--         fibre_rx_nrdy   <= '0';
--         wait for fibre_clkr_prd * 0.6;
--      elsif(skip_byte = '1') then
--         fibre_rx_nrdy   <= '1';
--         fibre_rx_data <= not data_valid(31 downto 24);
--         wait for fibre_clkr_prd * 0.4;
--         fibre_rx_nrdy   <= '0';
--         wait for fibre_clkr_prd * 0.6;
--      end if;
      ------------------------------------------------------------------------------------------

      fibre_rx_nrdy   <= '1';
      fibre_rx_data <= checksum(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data <= checksum(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

      fibre_rx_nrdy   <= '1';
      fibre_rx_data <= checksum(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_nrdy   <= '0';
      wait for fibre_clkr_prd * 0.6;

--      fibre_rx_nrdy   <= '1';
--      fibre_rx_data <= checksum(31 downto 24);
--      wait for fibre_clkr_prd * 0.4;
--      fibre_rx_nrdy   <= '0';
--      wait for fibre_clkr_prd * 0.6;

      if(skip_byte = '1') then
         -- Don't output the last byte

      elsif(add_byte = '1') then
         -- Output the last byte plus an extra one
         fibre_rx_nrdy   <= '1';
         fibre_rx_data <= checksum(31 downto 24);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

         -- Insert a PCI delay..  ??
         fibre_rx_nrdy <= '1';
         wait for pci_dsp_dly;
         fibre_rx_data <= x"A5";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

      elsif(wrong_checksum = '1') then
         -- Modify the checksum
         fibre_rx_nrdy   <= '1';
         fibre_rx_data <= not data_valid(31 downto 24);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;

      else
         -- Do the standard thing
         fibre_rx_nrdy   <= '1';
         fibre_rx_data <= checksum(31 downto 24);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_nrdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
      end if;

      assert false report "checksum loaded...." severity NOTE;

      fibre_rx_nrdy <= '1';
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


------------------------------------------------------
-- Begin Test
------------------------------------------------------

   begin

      -- Wait for the BRst to finish, which takes 100us
      present_sim_state <= NOTHING;
      wait for 150 us;

--      command <= command_wb;
--      address_id <= rc1_fb_const_cmd;
--      data_valid <= X"00000008";
--      data       <= X"00000FFF";         
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 100 us;

      command <= command_wb;
      address_id <= rc1_servo_mode_cmd;
      data_valid <= X"00000001";
      data       <= X"00000003";
      load_preamble;
      load_command;
      load_checksum;
      wait for 100 us;

      command <= command_wb;
      address_id <= rc1_gaini0_cmd;
      data_valid <= X"00000001"; -- was x21
      data       <= X"000000FF"; --50
      load_preamble;
      load_command;
      load_checksum;
      wait for 100 us;      

      command <= command_wb;
      address_id <= rc1_sample_num_cmd;
      data_valid <= X"00000001";
      data       <= X"00000020"; -- was 10
      load_preamble;
      load_command;
      load_checksum;
      wait for 100 us;      
     
      command <= command_wb;
      address_id <= rc1_flx_quanta0_cmd;
      data_valid <= X"00000001";
      data       <= X"00001000"; -- RC1, flx_quanta0, row 0
      load_preamble;
      load_command;
      load_checksum;
      wait for 100 us;

--      command <= command_wb;
--      address_id <= rc1_flx_quanta1_cmd;
--      data_valid <= X"00000029";
--      data       <= X"00001000"; -- RC1, flx_quanta0, row 0
--      load_preamble;
--      load_command;
--      load_checksum;
--      wait for 100 us;

      command <= command_wb;
      address_id <= rc1_en_fb_jump_cmd;
      data_valid <= X"00000001";
      data       <= X"00000001";
      load_preamble;
      load_command;
      load_checksum;
      wait for 100 us;

      command <= command_wb;
      address_id <= rc1_flx_lp_init_cmd;
      data_valid <= X"00000001";
      data       <= X"00000001";
      load_preamble;
      load_command;
      load_checksum;
      wait for 4000 us;
      
      command <= command_wb;
      address_id <= rc1_flx_lp_init_cmd;
      data_valid <= X"00000001";
      data       <= X"00000001";
      load_preamble;
      load_command;
      load_checksum;
      wait for 4000 us;
------------------------------------------------------

      assert false report "Simulation done." severity FAILURE;
   end process stimuli;

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

   jtag : process
      
      procedure toggle_tdo is
      begin
         wait for 320 ns;
         if(jtag_loopback = '1') then
            jtag_loopback <= '0';
         else
            jtag_loopback <= '1';
         end if;
      end toggle_tdo;
   
   begin
      --assert false report "Waiting to toggle TDO" severity NOTE;
      --wait for 303340 ns;
      assert false report "Toggling TDO" severity NOTE;
      loop toggle_tdo;
      end loop;
   end process jtag;

end tb;