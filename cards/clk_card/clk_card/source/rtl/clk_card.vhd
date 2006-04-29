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
-- $Id: clk_card.vhd,v 1.38 2006/04/26 22:55:08 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Clock card top-level file
--
-- Revision history:
-- $Log: clk_card.vhd,v $
-- Revision 1.38  2006/04/26 22:55:08  bburger
-- Bryce:  Added a slave to Clock Card called config_fpga, which allows the user to toggle between factory and application configurations.
-- In the process:
-- - fixed a bug in cmd_translator_simple_cmd_fsm that output the wrong read/write code.
-- - updated the cc_pin_assign_rev_b.tcl file to include the fpga output pins for epc16 control
-- - updated the clock card top level with a new version number.
--
-- Revision 1.37  2006/04/03 23:24:37  bburger
-- Bryce:  uses frame_timing_pack
--
-- Revision 1.36  2006/03/17 21:25:45  bburger
-- Bryce:  cc_v02000005_17mar2006, cmd_translator now uses the card address specified by the ret_dat command.
--
-- Revision 1.35  2006/03/17 16:58:04  bburger
-- Bryce:  cc_v02000004_17mar2006
--
-- Revision 1.34  2006/03/16 19:22:13  bburger
-- Bryce:  comitting v02000003 for bus backplane revC
--
-- Revision 1.33  2006/03/16 00:25:46  bburger
-- Bryce:  committing v02000002
--
-- Revision 1.32  2006/03/08 23:18:08  bburger
-- Bryce:
-- - Added a 'use_sync' command
-- - Instantiated frame_timing and dv_rx blocks
-- - Added dv triggering signals to issue_reply interface
--
-- Revision 1.31  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.30  2006/02/09 20:32:59  bburger
-- Bryce:
-- - Added a fltr_rst_o output signal from the frame_timing block
-- - Adjusted the top-levels of each card to reflect the frame_timing interface change
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.leds_pack.all;
use work.fw_rev_pack.all;
use work.sync_gen_pack.all;
use work.issue_reply_pack.all;
use work.cc_reset_pack.all;
use work.ret_dat_wbs_pack.all;
use work.frame_timing_pack.all;

entity clk_card is
   port(
      -- PLL input:
      inclk14           : in std_logic;
      rst_n             : in std_logic;
      
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
      
      -- miscellaneous ports:
      red_led           : out std_logic;
      ylw_led           : out std_logic;
      grn_led           : out std_logic;
      dip_sw3           : in std_logic;
      dip_sw4           : in std_logic;
      wdog              : out std_logic;
      slot_id           : in std_logic_vector(3 downto 0);
      card_id           : inout std_logic;
      smb_clk           : out std_logic;
      smb_data          : inout std_logic;
      
      -- debug ports:
      mictor_o          : out std_logic_vector(15 downto 1);
      mictorclk_o       : out std_logic;
      mictor_e          : out std_logic_vector(15 downto 1);
      mictorclk_e       : out std_logic;
      rs232_rx          : in std_logic;
      rs232_tx          : out std_logic;
      
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
end clk_card;

architecture top of clk_card is

-- The REVISION format is RRrrBBBB where 
--               RR is the major revision number
--               rr is the minor revision number
--               BBBB is the build number
constant CC_REVISION: std_logic_vector (31 downto 0) := X"02000008";

-- reset
signal rst                : std_logic;
signal sc_rst             : std_logic;    -- reset signal generated by Linux PC issuing a 'special character' byte down the fibre

-- clocks
signal clk                : std_logic;
signal clk_n              : std_logic;
signal comm_clk           : std_logic;
signal fibre_clk          : std_logic;

-- sync_gen interface
signal sync_num           : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
signal encoded_sync       : std_logic;
signal row_len            : integer;
signal num_rows           : integer;

-- ret_dat_wbs interface
signal start_seq_num      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal stop_seq_num       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_rate          : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
signal data_req           : std_logic;
signal data_ack           : std_logic;
signal dv_mode            : std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
signal external_dv        : std_logic;
signal external_dv_num    : std_logic_vector(DV_NUM_WIDTH-1 downto 0);
signal sync_mode          : std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
signal external_sync      : std_logic;
signal ret_dat_req        : std_logic;
signal ret_dat_done       : std_logic;

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;
constant data_dummy : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := (others => '0');
constant addr_dummy : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := (others => '0');
constant tga_dummy  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0) := (others => '0');
constant we_dummy   : std_logic := '0';
constant stb_dummy  : std_logic := '0';
constant cyc_dummy  : std_logic := '0';

-- wishbone bus (from slaves)
signal slave_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_ack           : std_logic;
signal led_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal led_ack             : std_logic;
signal sync_gen_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal sync_gen_ack        : std_logic;
signal frame_timing_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal frame_timing_ack    : std_logic;
signal slave_err           : std_logic;
signal fw_rev_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal fw_rev_ack          : std_logic;
signal ret_dat_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal ret_dat_ack         : std_logic;
signal id_thermo_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal id_thermo_ack       : std_logic;
signal fpga_thermo_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal fpga_thermo_ack     : std_logic;
signal config_fpga_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal config_fpga_ack     : std_logic;

-- lvds_tx interface
signal sync       : std_logic;
signal cmd        : std_logic;

-- lvds_rx interface
signal lvds_reply_cc_a     : std_logic;

-- For testing
signal debug             : std_logic_vector(31 downto 0);
signal fib_tx_data       : std_logic_vector (7 downto 0);
signal fib_tx_ena        : std_logic;

component config_fpga
   port(
      -- Clock and Reset:
      clk_i         : in std_logic;
      rst_i         : in std_logic;
      
      -- Wishbone Interface:
      dat_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i        : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i         : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i          : in std_logic;
      stb_i         : in std_logic;
      cyc_i         : in std_logic;
      dat_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o         : out std_logic;
      
      -- Configuration Interface
      config_n_o    : out std_logic;
      epc16_sel_n_o : out std_logic
   );     
end component;

component cc_pll
   port(
      inclk0 : in std_logic;
      e2     : out std_logic;
      c0     : out std_logic;
      c1     : out std_logic;
      c2     : out std_logic;
      c3     : out std_logic;
      e0     : out std_logic;
      e1     : out std_logic 
   );
end component;

component dispatch
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;     
     
     -- bus backplane interface (LVDS)
     lvds_cmd_i   : in std_logic;
     lvds_reply_o : out std_logic;
     
     -- wishbone slave interface
     dat_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     addr_o : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
     tga_o  : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
     we_o   : out std_logic;
     stb_o  : out std_logic;
     cyc_o  : out std_logic;
     dat_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     ack_i  : in std_logic;
     err_i  : in std_logic;
     
     -- misc. external interface
     wdt_rst_o : out std_logic;
     slot_i    : in std_logic_vector(3 downto 0);
     dip_sw3 : in std_logic;
     dip_sw4 : in std_logic);
end component;

component fpga_thermo
port(clk_i : in std_logic;
     rst_i : in std_logic;

     -- wishbone signals
     dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     ack_o   : out std_logic;
     
     -- SMBus temperature sensor signals
     smbclk_o : out std_logic;
     smbdat_io : inout std_logic);
end component;

component id_thermo
  port(
     clk_i : in std_logic;
     rst_i : in std_logic;
        
     -- Wishbone signals
     dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     ack_o   : out std_logic;
           
     -- silicon id/temperature chip signals
     data_io : inout std_logic
  );
end component;

component sync_gen
   port(
      -- Inputs/Outputs
      dv_mode_o            : out std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      sync_mode_o          : out std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      encoded_sync_o       : out std_logic;
      external_sync_i      : in std_logic;
      row_len_o            : out integer;
      num_rows_o           : out integer;

      -- Wishbone interface
      dat_i                : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i               : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                 : in std_logic;
      stb_i                : in std_logic;
      cyc_i                : in std_logic;
      dat_o                : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                : out std_logic;

      -- Global Signals
      clk_i                : in std_logic;
      rst_i                : in std_logic
   );
end component;

component frame_timing is
   port(
      -- Readout Card interface
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic; 
      restart_frame_1row_post_o  : out std_logic;
      initialize_window_o        : out std_logic;
      fltr_rst_o                 : out std_logic;
      sync_num_o                 : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      
      -- Address Card interface
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
         
      -- Bias Card interface
      update_bias_o              : out std_logic;
      
      -- Wishbone interface
      dat_i                      : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                     : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                      : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                       : in std_logic;
      stb_i                      : in std_logic;
      cyc_i                      : in std_logic;
      dat_o                      : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                      : out std_logic;      
      
      -- Global signals
      clk_i                      : in std_logic;
      clk_n_i                    : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
end component;

component dv_rx
   port(
      -- Clock and Reset:
      clk_i             : in std_logic;
      clk_n_i           : in std_logic;
      rst_i             : in std_logic;
      
      -- Fibre Interface:
      manchester_dat_i  : in std_logic;
      dv_dat_i          : in std_logic;
      
      -- Issue-Reply Interface:
      dv_mode_i         : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      dv_o              : out std_logic;
      dv_sequence_num_o : out std_logic_vector(DV_NUM_WIDTH-1 downto 0);

      sync_mode_i       : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      sync_i            : in std_logic;
      sync_o            : out std_logic
   );     
end component;

component ret_dat_wbs is        
   port
   (
      -- cmd_translator interface:
      start_seq_num_o : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_o     : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      ret_dat_req_o   : out std_logic;
      ret_dat_ack_i   : in std_logic;

      -- global interface
      clk_i          : in std_logic;
      rst_i          : in std_logic; 
      
      -- wishbone interface:
      dat_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i         : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i          : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i           : in std_logic;
      stb_i          : in std_logic;
      cyc_i          : in std_logic;
      dat_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o          : out std_logic
   );     
end component;

component issue_reply
   port(
      -- for testing
      debug_o           : out std_logic_vector (31 downto 0);

      -- global signals
      rst_i             : in std_logic;
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;

      -- inputs from the bus backplane
      lvds_reply_ac_a   : in std_logic;  
      lvds_reply_bc1_a  : in std_logic;
      lvds_reply_bc2_a  : in std_logic;
      lvds_reply_bc3_a  : in std_logic;
      lvds_reply_rc1_a  : in std_logic;
      lvds_reply_rc2_a  : in std_logic;
      lvds_reply_rc3_a  : in std_logic; 
      lvds_reply_rc4_a  : in std_logic;
      lvds_reply_cc_a   : in std_logic;
      
      -- inputs from the fibre receiver 
      fibre_clkr_i      : in std_logic;
      rx_data_i         : in std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i         : in std_logic;
      rvs_i             : in std_logic;
      rso_i             : in std_logic;
      rsc_nRd_i         : in std_logic;        
      cksum_err_o       : out std_logic;

      -- interface to fibre transmitter
      tx_data_o         : out std_logic_vector (7 downto 0);      -- byte of data to be transmitted
      tsc_nTd_o         : out std_logic;                          -- hotlink tx special char/ data sel
      nFena_o           : out std_logic;                          -- hotlink tx enable

      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i      : in std_logic;                           -- in phase with 25MHz hotlink clock

      -- lvds_tx interface
      lvds_cmd_o        : out std_logic;                          -- transmitter output pin

      -- ret_dat_wbs interface:
      start_seq_num_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_i    : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_i       : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      dv_mode_i         : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i     : in std_logic;
      external_dv_num_i : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);
      ret_dat_req_i     : in std_logic;
      ret_dat_ack_o     : out std_logic;

      -- sync_gen interface
      row_len_i         : in integer;
      num_rows_i        : in integer;
      sync_pulse_i      : in std_logic;
      sync_number_i     : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
   );    
end component;

begin

   mictor_o(8 downto 1) <= fibre_rx_data;
   mictor_o(9)     <= fibre_rx_rdy;
   mictor_o(10)    <= lvds_reply_ac_a;
   mictor_o(11)    <= lvds_reply_bc1_a;
   mictor_o(12)    <= lvds_reply_bc2_a;
   mictor_o(13)    <= lvds_reply_bc3_a;
   
   mictor_e(8 downto 1) <= fib_tx_data;
   mictor_e(9)     <= fib_tx_ena;
   mictor_e(10)    <= lvds_reply_rc1_a;
   mictor_e(11)    <= lvds_reply_rc2_a;
   mictor_e(12)    <= lvds_reply_rc3_a;
   mictor_e(13)    <= lvds_reply_rc4_a;
   
   -- Fibre tx signals
   fibre_tx_data   <= fib_tx_data;
   fibre_tx_ena    <= fib_tx_ena;
   
   -- Fibre rx signals
   fibre_rx_a_nb   <= '1';
   fibre_rx_bisten <= '1'; 
   fibre_rx_rf     <= '1'; 
   
   -- This is an active-low enable signal for the TTL transmitter.  This line is used as a BClr.
   ttl_txena1 <= '0';
   
   -- ttl_tx1 is an active-low reset transmitted accross the bus backplane to clear FPGA registers (BClr)
   ttl_tx1    <= not sc_rst;
   
   rst        <= (not rst_n) or sc_rst;

   with addr select
      slave_data <=
         fw_rev_data       when FW_REV_ADDR,              
         led_data          when LED_ADDR,
         sync_gen_data     when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR,
         ret_dat_data      when RET_DAT_S_ADDR | DATA_RATE_ADDR,
         id_thermo_data    when CARD_TEMP_ADDR | CARD_ID_ADDR,
         fpga_thermo_data  when FPGA_TEMP_ADDR,
         config_fpga_data  when CONFIG_FAC_ADDR | CONFIG_APP_ADDR,
         (others => '0')   when others;
         
   with addr select
      slave_ack <= 
         fw_rev_ack        when FW_REV_ADDR,
         led_ack           when LED_ADDR,
         sync_gen_ack      when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR,
         ret_dat_ack       when RET_DAT_S_ADDR | DATA_RATE_ADDR,
         id_thermo_ack     when CARD_TEMP_ADDR | CARD_ID_ADDR,
         fpga_thermo_ack   when FPGA_TEMP_ADDR,
         config_fpga_ack   when CONFIG_FAC_ADDR | CONFIG_APP_ADDR,
         '0'               when others;
         
   with addr select
      slave_err <= 
         '0'              when FW_REV_ADDR | LED_ADDR | USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR | RET_DAT_S_ADDR | 
                               DATA_RATE_ADDR | CARD_ID_ADDR | CARD_TEMP_ADDR | FPGA_TEMP_ADDR |CONFIG_FAC_ADDR | CONFIG_APP_ADDR, 
                               --| SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '1'              when others;

   pll0: cc_pll
      port map(
         inclk0 => inclk14,
         c0     => clk,
         c1     => clk_n,
         c2     => comm_clk,
         c3     => fibre_clk,
         e0     => fibre_tx_clkw, 
         e1     => fibre_rx_refclk,   
         e2     => lvds_clk 
      );

   config_fpga_inst: config_fpga
      port map(
         -- Clock and Reset:
         clk_i         => clk,
         rst_i         => rst,
         
         -- Wishbone Interface:
         dat_i         => data,         
         addr_i        => addr,         
         tga_i         => tga,
         we_i          => we,          
         stb_i         => stb,          
         cyc_i         => cyc,       
         dat_o         => config_fpga_data,
         ack_o         => config_fpga_ack,
         
         -- Configuration Interface
         config_n_o    => nreconf,
         epc16_sel_n_o => nepc_sel
      );

   lvds_cmd <= cmd;
   cmd0: dispatch
      port map(
         lvds_cmd_i   => cmd,
         lvds_reply_o => lvds_reply_cc_a,
         
         --  Global signals
         clk_i      => clk,
         comm_clk_i => comm_clk,
         rst_i      => rst,
            
         -- Wishbone interface
         dat_o  => data,
         addr_o => addr,
         tga_o  => tga,
         we_o   => we,
         stb_o  => stb,
         cyc_o  => cyc,
         dat_i  => slave_data,   
         ack_i  => slave_ack,
         err_i  => slave_err, 
     
         wdt_rst_o => wdog,
         slot_i    => slot_id,
         dip_sw3   => '1',
         dip_sw4   => '1'
      );
            
   led0: leds
      port map(   
         --  Global signals
         clk_i => clk,
         rst_i => rst,
            
         -- Wishbone interface
         dat_i  => data,
         addr_i => addr,
         tga_i  => tga,
         we_i   => we,
         stb_i  => stb,
         cyc_i  => cyc,
         dat_o  => led_data,
         ack_o  => led_ack,
      
         power  => grn_led,
         status => ylw_led,
         fault  => red_led
      );

   fw_rev_slave: fw_rev
      generic map( REVISION => CC_REVISION)
      port map(
         clk_i  => clk,
         rst_i  => rst,

         dat_i  => data,
         addr_i => addr,
         tga_i  => tga,
         we_i   => we,
         stb_i  => stb,
         cyc_i  => cyc,
         dat_o  => fw_rev_data,
         ack_o  => fw_rev_ack
    );

   id_thermo0: id_thermo
      port map(
         clk_i   => clk,
         rst_i   => rst,  
         
         -- Wishbone signals
         dat_i   => data, 
         addr_i  => addr,
         tga_i   => tga,
         we_i    => we,
         stb_i   => stb,
         cyc_i   => cyc,
         dat_o   => id_thermo_data,
         ack_o   => id_thermo_ack,
            
         -- silicon id/temperature chip signals
         data_io => card_id);
         
   fpga_thermo0: fpga_thermo
      port map(
         clk_i   => clk,
         rst_i   => rst,  
         
         -- Wishbone signals
         dat_i   => data, 
         addr_i  => addr,
         tga_i   => tga,
         we_i    => we,
         stb_i   => stb,
         cyc_i   => cyc,
         dat_o   => fpga_thermo_data,
         ack_o   => fpga_thermo_ack,
            
         -- FPGA temperature chip signals
         smbclk_o => smb_clk,
         smbdat_io => smb_data);
      
   lvds_sync <= encoded_sync;
   
   sync_gen0: sync_gen
      port map( 
         -- Inputs/Outputs
         dv_mode_o            => dv_mode,
         sync_mode_o          => sync_mode,
         encoded_sync_o       => encoded_sync,
         external_sync_i      => external_sync,
         row_len_o            => row_len,
         num_rows_o           => num_rows,
      
         -- Wishbone interface
         dat_i                => data,         
         addr_i               => addr,           
         tga_i                => tga,
         we_i                 => we,          
         stb_i                => stb,            
         cyc_i                => cyc,       
         dat_o                => sync_gen_data,          
         ack_o                => sync_gen_ack,
      
         --  Global signals
         clk_i                => clk,
         rst_i                => rst
      );

   frame_timing_slave: frame_timing
      port map(
         dac_dat_en_o               => open,
         adc_coadd_en_o             => open,
         restart_frame_1row_prev_o  => open,
         restart_frame_aligned_o    => sync,
         restart_frame_1row_post_o  => open,
         initialize_window_o        => open,
         sync_num_o                 => sync_num,
         
         row_switch_o               => open,
         row_en_o                   => open,
            
         update_bias_o              => open,
         
         dat_i                      => data_dummy,
         addr_i                     => addr_dummy,
         tga_i                      => tga_dummy, 
         we_i                       => we_dummy,  
         stb_i                      => stb_dummy, 
         cyc_i                      => cyc_dummy,
         dat_o                      => open,
         ack_o                      => open,
         
         clk_i                      => clk,
         clk_n_i                    => clk_n,
         rst_i                      => rst,
         sync_i                     => encoded_sync
      );

   dv_rx_inst: dv_rx
      port map(
         -- Clock and Reset:
         clk_i             => clk,
         clk_n_i           => clk_n,
         rst_i             => rst,
         
         -- Fibre Interface
         manchester_dat_i  => manchester_data,
         dv_dat_i          => dv_pulse_fibre,
         
         -- Issue-Reply Interface:
         dv_mode_i         => dv_mode,
         dv_o              => external_dv,
         dv_sequence_num_o => external_dv_num,

         sync_mode_i       => sync_mode,
         sync_i            => sync,
         sync_o            => external_sync
      );

   issue_reply0: issue_reply
      port map(   
         -- For testing
         debug_o    => debug,
   
         -- global signals
         rst_i             => rst,
         clk_i             => clk,
         comm_clk_i        => comm_clk,
         
         -- bus backplane interface
         lvds_reply_ac_a   => lvds_reply_ac_a,   
         lvds_reply_bc1_a  => lvds_reply_bc1_a,
         lvds_reply_bc2_a  => lvds_reply_bc2_a,
         lvds_reply_bc3_a  => lvds_reply_bc3_a,
         lvds_reply_rc1_a  => lvds_reply_rc1_a,
         lvds_reply_rc2_a  => lvds_reply_rc2_a,
         lvds_reply_rc3_a  => lvds_reply_rc3_a, 
         lvds_reply_rc4_a  => lvds_reply_rc4_a,
         lvds_reply_cc_a   => lvds_reply_cc_a,

         -- fibre receiver interface 
         fibre_clkr_i      => fibre_rx_clkr,  
         rx_data_i         => fibre_rx_data,
         nRx_rdy_i         => fibre_rx_rdy,
         rvs_i             => fibre_rx_rvs,
         rso_i             => fibre_rx_status,
         rsc_nRd_i         => fibre_rx_sc_nd,
         cksum_err_o       => open,
    
         -- fibre transmitter interface
         tx_data_o         => fib_tx_data,     -- byte of data to be transmitted
         tsc_nTd_o         => fibre_tx_sc_nd,    -- hotlink tx special char/ data sel
         nFena_o           => fib_tx_ena,      -- hotlink tx enable
   
         -- 25MHz clock for fibre_tx_control
         fibre_clkw_i      => fibre_clk,
        
         -- lvds_tx interface
         lvds_cmd_o        => cmd,

         -- ret_dat_wbs interface:
         start_seq_num_i   => start_seq_num,
         stop_seq_num_i    => stop_seq_num,
         data_rate_i       => data_rate,
         dv_mode_i         => dv_mode,
         external_dv_i     => external_dv,
         external_dv_num_i => external_dv_num,
         ret_dat_req_i     => ret_dat_req,
         ret_dat_ack_o     => ret_dat_done,
         
         -- sync_gen interface
         row_len_i         => row_len,
         num_rows_i        => num_rows,
         sync_pulse_i      => sync,
         sync_number_i     => sync_num
      );      
      
   cc_reset0: cc_reset
      port map ( 
         clk_i      =>  clk,
         rst_n_i    =>  rst_n,
         nRx_rdy_i  =>  fibre_rx_rdy,
         rsc_nRd_i  =>  fibre_rx_sc_nd,
         rso_i      =>  fibre_rx_status,
         rvs_i      =>  fibre_rx_rvs,
         rx_data_i  =>  fibre_rx_data,
         reset_o    =>  sc_rst     
      );

   ret_dat_param: ret_dat_wbs       
      port map
      (
         -- cmd_translator interface:
         start_seq_num_o => start_seq_num,
         stop_seq_num_o  => stop_seq_num,
         data_rate_o     => data_rate,
         ret_dat_req_o   => ret_dat_req,
         ret_dat_ack_i   => ret_dat_done,

         -- global interface
         clk_i           => clk,
         rst_i           => rst, 
         
         -- wishbone interface:
         dat_i           => data,         
         addr_i          => addr,         
         tga_i           => tga,
         we_i            => we,          
         stb_i           => stb,          
         cyc_i           => cyc,       
         dat_o           => ret_dat_data,
         ack_o           => ret_dat_ack
      );
      
end top;