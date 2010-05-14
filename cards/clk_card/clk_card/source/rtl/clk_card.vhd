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
-- $Id: clk_card.vhd,v 1.96 2010/04/20 23:31:41 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger/ Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Clock card top-level file
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.all_cards_pack.all;
use work.clk_card_pack.all;
use work.sync_gen_pack.all;
use work.issue_reply_pack.all;
use work.frame_timing_pack.all;
use work.ret_dat_wbs_pack.all;

entity clk_card is
   port(
      -- Crystal Clock PLL input:
      inclk14           : in std_logic; -- Crystal Clock Input
      rst_n             : in std_logic;

      -- Manchester Clock PLL inputs:
      inclk15           : in std_logic; -- Enhanced PLL, for clock switchover.
      inclk1            : in std_logic; -- Fast PLL
      inclk5            : in std_logic; -- Enhanced PLL

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
      ttl_nrx1          : in std_logic;  -- N/A
      ttl_tx1           : out std_logic; -- BClr
      ttl_txena1        : out std_logic; -- BClr

      ttl_nrx2          : in std_logic;  -- 1+ Dead Card
      ttl_tx2           : out std_logic; -- N/A
      ttl_txena2        : out std_logic; -- 1+ Dead Card 

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
--      crc_error_out     : inout std_logic;

      -- debug ports:
--      auto_stp_trigger_out_0 : out std_logic;
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
      
      nreconf           : out std_logic; -- To CPLD: triggers a reconfiguration
      nepc_sel          : out std_logic  -- To CPLD: selects factory/application EPC16
   );
end clk_card;

architecture top of clk_card is

   -- The REVISION format is RRrrBBBB where
   --               RR is the major revision number
   --               rr is the minor revision number
   --               BBBB is the build number
   constant CC_REVISION: std_logic_vector (31 downto 0) := X"05000007";

   -- reset
   signal rst                : std_logic;
   signal cc_bclr            : std_logic;    -- reset signal generated by Linux PC issuing a 'special character' byte down the fibre
   signal mce_bclr           : std_logic;

   -- clocks
   signal clk                : std_logic;
   signal clk_n              : std_logic;
   signal comm_clk           : std_logic;
   signal fibre_clk          : std_logic;
   signal manch_clk          : std_logic;

   -- sync_gen interface
   signal sync_num           : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal encoded_sync       : std_logic;
   signal row_len            : integer;
   signal num_rows           : integer;

   -- ret_dat_wbs interface
   signal start_seq_num        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal stop_seq_num         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal data_rate            : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal data_req             : std_logic;
   signal data_ack             : std_logic;
   signal dv_mode              : std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
   signal external_dv          : std_logic;
   signal external_dv_num      : std_logic_vector(DV_NUM_WIDTH-1 downto 0);
   signal sync_mode            : std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
   signal external_sync        : std_logic;
   signal ret_dat_req          : std_logic;
   signal ret_dat_done         : std_logic;
   signal tes_bias_toggle_en   : std_logic;
   signal tes_bias_high        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_bias_low         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_bias_toggle_rate : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal status_cmd_en        : std_logic;
   signal crc_err_en           : std_logic;

   -- sram_ctrl interface
   signal sram_addr : std_logic_vector(19 downto 0);
   signal sram_data : std_logic_vector(31 downto 0);
   signal sram_nbhe : std_logic;
   signal sram_nble : std_logic;
   signal sram_noe  : std_logic;
   signal sram_nwe  : std_logic;
   signal sram_nce1 : std_logic;
   signal sram_ce2  : std_logic;

   -- PSUC dispatch block
   signal psu_slave_err  : std_logic;
   signal psu_slave_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal psu_slave_ack  : std_logic;

   signal psu_slave_err2  : std_logic;
   signal psu_slave_data2 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal psu_slave_ack2  : std_logic;

   signal psu_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal psu_addr       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
   signal psu_tga        : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
   signal psu_we         : std_logic;
   signal psu_stb        : std_logic;
   signal psu_cyc        : std_logic;

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
   signal slave_err  : std_logic;
   signal slave_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal slave_ack  : std_logic;

   signal led_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal led_ack             : std_logic;

   signal sync_gen_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal sync_gen_ack        : std_logic;

   signal frame_timing_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal frame_timing_ack    : std_logic;

   signal fw_rev_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fw_rev_ack          : std_logic;
   signal fw_rev_err          : std_logic;

   signal ret_dat_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ret_dat_ack         : std_logic;
   signal ret_dat_err         : std_logic;

   signal card_id_thermo_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal card_id_thermo_ack  : std_logic;
   signal card_id_thermo_err  : std_logic;

   signal backplane_id_thermo_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal backplane_id_thermo_ack   : std_logic;
   signal backplane_id_thermo_err   : std_logic;

   signal fpga_thermo_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fpga_thermo_ack     : std_logic;
   signal fpga_thermo_err     : std_logic;

   signal config_fpga_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal config_fpga_ack     : std_logic;

   signal select_clk_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal select_clk_ack      : std_logic;

   signal psu_ctrl_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal psu_ctrl_ack        : std_logic;

   signal sram_ctrl_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal sram_ctrl_ack       : std_logic;

   signal slot_id_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal slot_id_ack         : std_logic;
   signal slot_id_err         : std_logic;

   signal array_id_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal array_id_ack        : std_logic;
   signal array_id_err        : std_logic;

   signal cc_reset_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal cc_reset_ack        : std_logic;

   signal all_cards_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal all_cards_ack       : std_logic;
   signal all_cards_err       : std_logic;

   -- lvds_tx interface
   signal sync : std_logic;
   signal cmd  : std_logic;

   -- lvds_rx interface
   signal lvds_reply_cc_a  : std_logic;
   signal lvds_reply_psu_a : std_logic;
   signal lvds_reply_cc_b  : std_logic;
   signal lvds_reply_psu_b : std_logic;
   signal lvds_reply_all_a : std_logic_vector(9 downto 0);
   signal lvds_reply_all_b : std_logic_vector(9 downto 0);

   -- For testing
   signal debug       : std_logic_vector(31 downto 0);
   signal fib_tx_data : std_logic_vector (7 downto 0);
   signal fib_tx_ena  : std_logic;
   signal fib_tx_scnd : std_logic;

   -- The clock being used by the PLL to generate all others.
   -- 0 = crystal clock, 1 = manchester clock
   signal active_clk : std_logic;

   -- dv_rx interface signals
   signal sync_box_err      : std_logic;
   signal sync_box_err_ack  : std_logic;
   signal sync_box_free_run : std_logic;

   signal brst_event     : std_logic;
   signal mce_bclr_event : std_logic;
   signal cc_bclr_event  : std_logic;
   signal reset_event    : std_logic;
   signal reset_ack      : std_logic;

   signal num_rows_to_read   : integer;
   signal num_cols_to_read   : integer;
   signal internal_cmd_mode  : std_logic_vector(1 downto 0);
   signal step_period        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_minimum       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_size          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_maximum       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_param_id      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_card_addr     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_data_num      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal run_file_id        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal user_writable      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal stop_delay         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal card_not_present   : std_logic_vector(9 downto 0);
   signal cards_present      : std_logic_vector(9 downto 0);
   signal cards_to_report    : std_logic_vector(9 downto 0);
   signal rcs_to_report_data : std_logic_vector(9 downto 0);

   signal crc_error_ff : std_logic;

   signal awg_dat            : std_logic_vector(AWG_DAT_WIDTH-1 downto 0);
   signal awg_addr           : std_logic_vector(AWG_ADDR_WIDTH-1 downto 0);
   signal awg_addr_incr      : std_logic;

begin
   
   ----------------------------------------------------------------
   -- Manchester Clock Pll
   ----------------------------------------------------------------
   manch_pll_block : manch_pll
   port map (
      inclk0   => inclk1,
      c0       => manch_clk, -- 25MHz, in phase with the Manchester Clock from the Sync Box
      locked   => open
   );

   ----------------------------------------------------------------------------
   -- CRC_ERROR WYSIWYG Atom Instantiation
   ----------------------------------------------------------------------------
--   i_stratix_crcblock : stratix_crcblock
--   port map(
--      clk => clk,
--      shiftnld => '0',
--      ldsrc => '0',
--      crcerror => crc_error_out,
--      regout => open
--   );
--
--   -- According an539.pdf, p. 7:
--   -- To route the crcerror port to user I/O, you must insert a D flipflop (DFF) in between the crcerror port and the I/O.
--   i_d_flipflop : d_flipflop
--   PORT map(
--      clock => clk,
--      data  => crc_error_out,  
--      q     => crc_error_ff  
--   );
   
   ylw_led <= manchester_sigdet;
--   process(rst, clk)
--   begin
--      if(rst = '1') then
--         ylw_led <= '0';
--      elsif(clk'event and clk = '1') then
--         if(crc_error_ff = '1') then
--            ylw_led <= '1';
--         end if;
--      end if;
--   end process;
   ----------------------------------------------------------------------------

   -- Debug Signals
--   mictor0_o(7 downto 0) <= debug(7 downto 0);
--   mictor0_e(7 downto 0) <= fib_tx_data;
--   mictor0_e(8)          <= fib_tx_ena;
--   mictor0_e(9)          <= fib_tx_scnd;

   -- LED signals
   red_led <= fibre_rx_status;

   -- Fibre TX Signals
   fibre_tx_data   <= fib_tx_data;
   fibre_tx_ena    <= fib_tx_ena;
   fibre_tx_sc_nd  <= fib_tx_scnd;
   fibre_tx_enn    <= '1';
   fibre_tx_bisten <= '1';
   fibre_tx_foto   <= '0';

   -- Fibre RX Signals
   fibre_rx_a_nb   <= '1';
   fibre_rx_bisten <= '1';
   fibre_rx_rf     <= '1';

   -- Pulling ttl_txena1 low enables the TTL transmitter.  This line is used as a BClr.
   ttl_txena1 <= '0';   
   -- Pulling ttl_txena2 high enables the TTL receiver.  This line is used for detecting unresponsive cards.
   -- This line has a week pull up.  
   -- A card that is inserted and not configured would pull this line down, but this line would stay high if cards are inserted and configured.
   ttl_txena2 <= '1';

   -- ttl_tx1 is an active-low reset transmitted accross the bus backplane to clear FPGA registers (BClr)
   ttl_tx1 <= not mce_bclr;
   rst     <= cc_bclr or mce_bclr;

   -- LVDS line outputs
   lvds_sync <= encoded_sync;
   lvds_cmd  <= cmd;

   -- SRAM signals
   sram0_addr <= sram_addr(19 downto 0);
   sram1_addr <= sram_addr(19 downto 0);
   sram0_nbhe <= sram_nbhe;
   sram1_nbhe <= sram_nbhe;
   sram0_nble <= sram_nble;
   sram1_nble <= sram_nble;
   sram0_noe  <= sram_noe;
   sram1_noe  <= sram_noe;
   sram0_nwe  <= sram_nwe;
   sram1_nwe  <= sram_nwe;
   sram0_nce1 <= sram_nce1;
   sram1_nce1 <= sram_nce1;
   sram0_ce2  <= sram_ce2;
   sram1_ce2  <= sram_ce2;

   lvds_reply_all_a(AC)   <= lvds_reply_ac_a;
   lvds_reply_all_a(BC1)  <= lvds_reply_bc1_a;
   lvds_reply_all_a(BC2)  <= lvds_reply_bc2_a;
   lvds_reply_all_a(BC3)  <= lvds_reply_bc3_a;
   lvds_reply_all_a(RC1)  <= lvds_reply_rc1_a;
   lvds_reply_all_a(RC2)  <= lvds_reply_rc2_a;
   lvds_reply_all_a(RC3)  <= lvds_reply_rc3_a;
   lvds_reply_all_a(RC4)  <= lvds_reply_rc4_a;
   lvds_reply_all_a(CC)   <= lvds_reply_cc_a;
   lvds_reply_all_a(PSUC) <= lvds_reply_psu_a;

   lvds_reply_all_b(AC)   <= lvds_reply_ac_b;
   lvds_reply_all_b(BC1)  <= lvds_reply_bc1_b;
   lvds_reply_all_b(BC2)  <= lvds_reply_bc2_b;
   lvds_reply_all_b(BC3)  <= lvds_reply_bc3_b;
   lvds_reply_all_b(RC1)  <= lvds_reply_rc1_b;
   lvds_reply_all_b(RC2)  <= lvds_reply_rc2_b;
   lvds_reply_all_b(RC3)  <= lvds_reply_rc3_b;
   lvds_reply_all_b(RC4)  <= lvds_reply_rc4_b;
   lvds_reply_all_b(CC)   <= lvds_reply_cc_b;
   lvds_reply_all_b(PSUC) <= lvds_reply_psu_b;

--   -- Bits are active-high
--   card_not_present <=
--      lvds_reply_ac_b &
--      lvds_reply_bc1_b &
--      lvds_reply_bc2_b &
--      lvds_reply_bc3_b &
--      lvds_reply_rc1_b &
--      lvds_reply_rc2_b &
--      lvds_reply_rc3_b &
--      lvds_reply_rc4_b &
--      '0' & -- Clock Card
--      '0';  -- PSUC

   ----------------------------------------------------------------
   -- Autonomous Clock Card Reset Block
   ----------------------------------------------------------------
   -- At the moment, no differentiation is made between types of resets in the frame header.
   reset_event <= brst_event or mce_bclr_event or cc_bclr_event;

   cc_reset_block: cc_reset
   port map(
      clk_i        => clk,
      fibre_clkr_i => fibre_rx_clkr,

      -- These signals will eventually be stored in reply-packet headers
      brst_event_o     => brst_event,
      brst_ack_i       => reset_ack,
      mce_bclr_event_o => mce_bclr_event,
      mce_bclr_ack_i   => reset_ack,
      cc_bclr_event_o  => cc_bclr_event,
      cc_bclr_ack_i    => reset_ack,

      -- Fibre signals
      nRx_rdy_i    => fibre_rx_rdy,
      rsc_nRd_i    => fibre_rx_sc_nd,
      rso_i        => fibre_rx_status,
      rvs_i        => fibre_rx_rvs,
      rx_data_i    => fibre_rx_data,

      -- Register Clear Signals
      ext_rst_n_i  => rst_n,
      cc_bclr_o    => cc_bclr,
      mce_bclr_o   => mce_bclr,

      dat_i        => data,
      addr_i       => addr,
      tga_i        => tga,
      we_i         => we,
      stb_i        => stb,
      cyc_i        => cyc,
      dat_o        => cc_reset_data,
      ack_o        => cc_reset_ack
   );

   ----------------------------------------------------------------
   -- Clock Card Dispatch Block and Slaves
   ----------------------------------------------------------------
   -- Wishbone signals
   with addr select
      slave_data <=
         frame_timing_data   when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
         led_data            when LED_ADDR,
--         sync_gen_data       when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR,
         sync_gen_data       when USE_DV_ADDR | USE_SYNC_ADDR,
         config_fpga_data    when CONFIG_FAC_ADDR | CONFIG_APP_ADDR | JTAG0_ADDR | JTAG1_ADDR | JTAG2_ADDR | TMS_TDI_ADDR | TDO_ADDR | TDO_SAMPLE_DLY_ADDR | TCK_HALF_PERIOD_ADDR,
         select_clk_data     when SELECT_CLK_ADDR,
         sram_ctrl_data      when SRAM_ADDR_ADDR | SRAM_DATA_ADDR,
         all_cards_data      when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         ret_dat_data        when RET_DAT_S_ADDR | DATA_RATE_ADDR | TES_TGL_EN_ADDR | TES_TGL_MAX_ADDR | TES_TGL_MIN_ADDR |
                                  TES_TGL_RATE_ADDR | INT_CMD_EN_ADDR | CRC_ERR_EN_ADDR |
                                  INTERNAL_CMD_MODE_ADDR | RAMP_STEP_PERIOD_ADDR | RAMP_MIN_VAL_ADDR |
                                  RAMP_STEP_SIZE_ADDR | RAMP_MAX_VAL_ADDR | RAMP_PARAM_ID_ADDR | RAMP_CARD_ADDR_ADDR |
                                  RAMP_STEP_DATA_NUM_ADDR | RUN_ID_ADDR | USER_WRITABLE_ADDR | CARDS_TO_REPORT_ADDR |
                                  CARDS_PRESENT_ADDR | RET_DAT_REQ_ADDR | RCS_TO_REPORT_DATA_ADDR | STOP_DLY_ADDR |
                                  AWG_SEQUENCE_LEN_ADDR | AWG_ADDR_ADDR | AWG_DATA_ADDR,
         card_id_thermo_data when CARD_TEMP_ADDR | CARD_ID_ADDR,
         backplane_id_thermo_data when BOX_TEMP_ADDR | BOX_ID_ADDR,
         fpga_thermo_data    when FPGA_TEMP_ADDR,
         array_id_data       when ARRAY_ID_ADDR,
         cc_reset_data       when MCE_BCLR_ADDR | CC_BCLR_ADDR,
         (others => '0')     when others;

   with addr select
      slave_ack <=
         frame_timing_ack    when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
         led_ack             when LED_ADDR,
--         sync_gen_ack        when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR,
         sync_gen_ack        when USE_DV_ADDR | USE_SYNC_ADDR,
         config_fpga_ack     when CONFIG_FAC_ADDR | CONFIG_APP_ADDR | JTAG0_ADDR | JTAG1_ADDR | JTAG2_ADDR | TMS_TDI_ADDR | TDO_ADDR | TDO_SAMPLE_DLY_ADDR | TCK_HALF_PERIOD_ADDR,
         select_clk_ack      when SELECT_CLK_ADDR,
         sram_ctrl_ack       when SRAM_ADDR_ADDR | SRAM_DATA_ADDR,
         all_cards_ack       when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         ret_dat_ack         when RET_DAT_S_ADDR | DATA_RATE_ADDR | TES_TGL_EN_ADDR | TES_TGL_MAX_ADDR | TES_TGL_MIN_ADDR |
                                  TES_TGL_RATE_ADDR | INT_CMD_EN_ADDR | CRC_ERR_EN_ADDR |
                                  INTERNAL_CMD_MODE_ADDR | RAMP_STEP_PERIOD_ADDR | RAMP_MIN_VAL_ADDR |
                                  RAMP_STEP_SIZE_ADDR | RAMP_MAX_VAL_ADDR | RAMP_PARAM_ID_ADDR | RAMP_CARD_ADDR_ADDR |
                                  RAMP_STEP_DATA_NUM_ADDR | RUN_ID_ADDR | USER_WRITABLE_ADDR | CARDS_TO_REPORT_ADDR |
                                  CARDS_PRESENT_ADDR | RET_DAT_REQ_ADDR | RCS_TO_REPORT_DATA_ADDR | STOP_DLY_ADDR |
                                  AWG_SEQUENCE_LEN_ADDR | AWG_ADDR_ADDR | AWG_DATA_ADDR,
         card_id_thermo_ack  when CARD_TEMP_ADDR | CARD_ID_ADDR,
         backplane_id_thermo_ack  when BOX_TEMP_ADDR | BOX_ID_ADDR,
         fpga_thermo_ack     when FPGA_TEMP_ADDR,
         array_id_ack        when ARRAY_ID_ADDR,
         cc_reset_ack        when MCE_BCLR_ADDR | CC_BCLR_ADDR,
         '0'                 when others;

   with addr select
      slave_err <=
         '0'                 when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR |
                                  LED_ADDR |
--                                  USE_DV_ADDR | USE_SYNC_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR |
                                  USE_DV_ADDR | USE_SYNC_ADDR | 
                                  CONFIG_FAC_ADDR | CONFIG_APP_ADDR | JTAG0_ADDR | JTAG1_ADDR | JTAG2_ADDR | TMS_TDI_ADDR | TDO_ADDR | TDO_SAMPLE_DLY_ADDR | TCK_HALF_PERIOD_ADDR |
                                  SELECT_CLK_ADDR |
                                  SRAM_ADDR_ADDR | SRAM_DATA_ADDR,
         all_cards_err       when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         ret_dat_err         when RET_DAT_S_ADDR | DATA_RATE_ADDR | TES_TGL_EN_ADDR | TES_TGL_MAX_ADDR | TES_TGL_MIN_ADDR |
                                  TES_TGL_RATE_ADDR | INT_CMD_EN_ADDR | CRC_ERR_EN_ADDR |
                                  INTERNAL_CMD_MODE_ADDR | RAMP_STEP_PERIOD_ADDR | RAMP_MIN_VAL_ADDR |
                                  RAMP_STEP_SIZE_ADDR | RAMP_MAX_VAL_ADDR | RAMP_PARAM_ID_ADDR | RAMP_CARD_ADDR_ADDR |
                                  RAMP_STEP_DATA_NUM_ADDR | RUN_ID_ADDR | USER_WRITABLE_ADDR | CARDS_TO_REPORT_ADDR |
                                  CARDS_PRESENT_ADDR | RET_DAT_REQ_ADDR | RCS_TO_REPORT_DATA_ADDR | STOP_DLY_ADDR |
                                  AWG_SEQUENCE_LEN_ADDR | AWG_ADDR_ADDR | AWG_DATA_ADDR,
         card_id_thermo_err  when CARD_TEMP_ADDR | CARD_ID_ADDR,
         backplane_id_thermo_err  when BOX_TEMP_ADDR | BOX_ID_ADDR,
         fpga_thermo_err     when FPGA_TEMP_ADDR,
         array_id_err        when ARRAY_ID_ADDR,
         '1'                 when others;

   cc_dispatch_block: dispatch
   port map(
      lvds_cmd_i   => cmd,

      lvds_replya_o => lvds_reply_cc_a,
      lvds_replyb_o => lvds_reply_cc_b,

      --  Global signals
      clk_i        => clk,
      comm_clk_i   => comm_clk,
      rst_i        => rst,

      -- Wishbone interface
      dat_o        => data,
      addr_o       => addr,
      tga_o        => tga,
      we_o         => we,
      stb_o        => stb,
      cyc_o        => cyc,
      dat_i        => slave_data,
      ack_i        => slave_ack,
      err_i        => slave_err,

      wdt_rst_o    => wdog,
      slot_i       => slot_id,
      dip_sw3      => '1', --dip_sw3,
      dip_sw4      => '1' --dip_sw4
   );

   issue_reply_block: issue_reply
   port map(
      -- For testing
      debug_o    => debug,

      -- global signals
      rst_i             => rst,
      clk_i             => clk,
      clk_n_i           => clk_n,
      comm_clk_i        => comm_clk,

      -- bus backplane interface
      lvds_reply_all_a_i => lvds_reply_all_a,
      lvds_reply_all_b_i => lvds_reply_all_b,
      card_not_present_o => card_not_present,

      -- fibre receiver interface
      fibre_clkr_i      => fibre_rx_clkr,
      rx_data_i         => fibre_rx_data,
      nRx_rdy_i         => fibre_rx_rdy,
      rvs_i             => fibre_rx_rvs,
      rso_i             => fibre_rx_status,
      rsc_nRd_i         => fibre_rx_sc_nd,

      -- fibre transmitter interface
      tx_data_o         => fib_tx_data,     -- byte of data to be transmitted
      tsc_nTd_o         => fib_tx_scnd,  -- hotlink tx special char/ data sel
      nFena_o           => fib_tx_ena,      -- hotlink tx enable

      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i      => fibre_clk,

      -- lvds_tx interface
      lvds_cmd_o        => cmd,

      -- ret_dat signals (from ret_dat_wbs)
      start_seq_num_i      => start_seq_num,
      stop_seq_num_i       => stop_seq_num,
      data_rate_i          => data_rate,
      internal_cmd_mode_i  => internal_cmd_mode,
      step_period_i        => step_period,
      step_minimum_i       => step_minimum,
      step_size_i          => step_size,
      step_maximum_i       => step_maximum,
      step_param_id_i      => step_param_id,
      step_card_addr_i     => step_card_addr,
      step_data_num_i      => step_data_num,
      crc_err_en_i         => crc_err_en,
      num_rows_to_read_i   => num_rows_to_read,
      num_cols_to_read_i   => num_cols_to_read,
      run_file_id_i        => run_file_id,
      user_writable_i      => user_writable,
      stop_delay_i         => stop_delay,
      ret_dat_req_i        => ret_dat_req,
      ret_dat_ack_o        => ret_dat_done,
      cards_to_report_i    => cards_to_report,
      rcs_to_report_data_i => rcs_to_report_data,
      awg_dat_i            => awg_dat,   
      awg_addr_i           => awg_addr,
      awg_addr_incr_o      => awg_addr_incr,
      dead_card_i          => ttl_nrx2,
      
      -- dv_rx interface
      external_dv_i        => external_dv,
      external_dv_num_i    => external_dv_num,
      sync_box_err_i       => sync_box_err,
      sync_box_err_ack_o   => sync_box_err_ack,
      sync_box_free_run_i  => sync_box_free_run,

      -- cc_reset interface
      reset_event_i        => reset_event,
      reset_ack_o          => reset_ack,

      -- clk_switchover interface
      active_clk_i         => active_clk,

      -- sync_gen interface
      dv_mode_i            => dv_mode,
      row_len_i            => row_len,
      num_rows_i           => num_rows,

      -- frame_timing interface
      sync_pulse_i         => sync,
      sync_number_i        => sync_num
   );

   i_all_cards: all_cards
   generic map(
      REVISION => CC_REVISION,
      CARD_TYPE=> CC_CARD_TYPE)
   port map(
      clk_i  => clk,
      rst_i  => rst,

      dat_i  => data,
      addr_i => addr,
      tga_i  => tga,
      we_i   => we,
      stb_i  => stb,
      cyc_i  => cyc,
      slot_id_i => slot_id,
      err_o           => all_cards_err,
      dat_o           => all_cards_data,
      ack_o           => all_cards_ack
   );

--   slot_id_slave : bp_slot_id
--   port map(
--      clk_i  => clk,
--      rst_i  => rst,
--
--      slot_id_i => slot_id,
--
--      dat_i  => data,
--      addr_i => addr,
--      tga_i  => tga,
--      we_i   => we,
--      stb_i  => stb,
--      cyc_i  => cyc,
--      err_o  => slot_id_err,
--      dat_o  => slot_id_data,
--      ack_o  => slot_id_ack
--   );

   fw_rev_slave: fw_rev
   generic map(REVISION => CC_REVISION)
   port map(
      clk_i  => clk,
      rst_i  => rst,

      dat_i  => data,
      addr_i => addr,
      tga_i  => tga,
      we_i   => we,
      stb_i  => stb,
      cyc_i  => cyc,
      err_o  => fw_rev_err,
      dat_o  => fw_rev_data,
      ack_o  => fw_rev_ack
   );

   array_id_slave : subarray_id
   port map(
      clk_i  => clk,
      rst_i  => rst,

      array_id_i => array_id,

      dat_i  => data,
      addr_i => addr,
      tga_i  => tga,
      we_i   => we,
      stb_i  => stb,
      cyc_i  => cyc,
      err_o  => array_id_err,
      dat_o  => array_id_data,
      ack_o  => array_id_ack
   );

   sram_ctrl_slave: sram_ctrl
   port map(
      -- SRAM signals:
      addr_o  => sram_addr,
      data_bi(15 downto 0) => sram0_data,
      data_bi(31 downto 16) => sram1_data,
      n_ble_o => sram_nble,
      n_bhe_o => sram_nbhe,
      n_oe_o  => sram_noe,
      n_ce1_o => sram_nce1,
      ce2_o   => sram_ce2,
      n_we_o  => sram_nwe,

      -- wishbone signals:
      clk_i   => clk,
      rst_i   => rst,
      dat_i   => data,
      addr_i  => addr,
      tga_i   => tga,
      we_i    => we,
      stb_i   => stb,
      cyc_i   => cyc,
      dat_o   => sram_ctrl_data,
      ack_o   => sram_ctrl_ack
   );

   -- E0 is 180 degrees out of phase with C3 to ensure that the rising edge of fibre_tx_ena occurs at least 5ns before the rising edge of fibre_tx_clkw.
   -- That is a spec-sheet requirement.
   -- This should ensure that there is no metastability.
   clk_switchover_slave: clk_switchover
   port map(
      -- wishbone interface:
      dat_i               => data,
      addr_i              => addr,
      tga_i               => tga,
      we_i                => we,
      stb_i               => stb,
      cyc_i               => cyc,
      dat_o               => select_clk_data,
      ack_o               => select_clk_ack,

      rst_i               => rst,
      xtal_clk_i          => inclk14, -- Crystal Clock Input
      manch_clk_i         => inclk15,  -- Manchester Clock Input
      active_clk_o        => active_clk,
      c0_o                => clk,
      c1_o                => clk_n,
      c2_o                => comm_clk,
      c3_o                => fibre_clk,
      e0_o                => fibre_tx_clkw,  -- 180 degrees out of phase with fibre_clk
      e1_o                => fibre_rx_refclk,
      e2_o                => lvds_clk
   );

   config_fpga_slave: config_fpga
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

      -- JTAG interface
      fpga_tdo_o    => fpga_tdo,
      fpga_tck_o    => fpga_tck,
      fpga_tms_o    => fpga_tms,
      epc_tdo_i     => epc_tdo, 
      jtag_sel_o    => jtag_sel,
      nbb_jtag_i    => nbb_jtag,

      -- Configuration Interface
      config_n_o    => nreconf,
      epc16_sel_n_o => nepc_sel
   );

   led_slave: leds
   port map(
      --  Global signals
      clk_i  => clk,
      rst_i  => rst,

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
      status => open, --ylw_led,
      fault  => open --red_led
   );

   card_id_thermo_slave : id_thermo
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
      err_o   => card_id_thermo_err,
      dat_o   => card_id_thermo_data,
      ack_o   => card_id_thermo_ack,

      -- silicon id/temperature chip signals
      data_io => card_id
   );

   backplane_id_thermo_slave : backplane_id_thermo
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
      err_o   => backplane_id_thermo_err,
      dat_o   => backplane_id_thermo_data,
      ack_o   => backplane_id_thermo_ack,

      -- silicon id/temperature chip signals
      data_i => box_id_in,
      data_o => box_id_out,
      wren_n_o => box_id_ena_n
   );

   smb_nalert <= '0';
   fpga_thermo_slave: fpga_thermo
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
      err_o   => fpga_thermo_err,
      dat_o   => fpga_thermo_data,
      ack_o   => fpga_thermo_ack,

      -- FPGA temperature chip signals
      smbclk_o   => smb_clk,
      smbalert_i => '1',
      smbdat_io  => smb_data
   );

   sync_gen_slave: sync_gen
   port map(
      -- Inputs/Outputs
      dv_mode_o            => dv_mode,
      sync_mode_o          => sync_mode,
      encoded_sync_o       => encoded_sync,
      external_sync_i      => external_sync,
      row_len_i            => row_len,
      num_rows_i           => num_rows,

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

   -- Move the row_len and num_rows storage space from sync_gen to frame timing!!!
   -- Frame_timing is taking on a new nature.  It is sort of the global timing and readout slave.
   frame_timing_slave: frame_timing
   port map(
      dac_dat_en_o               => open,
      adc_coadd_en_o             => open,
      restart_frame_1row_prev_o  => open,
      restart_frame_aligned_o    => sync,
      restart_frame_1row_post_o  => open,
      initialize_window_o        => open,
      row_len_o                  => row_len,
      num_rows_o                 => num_rows,
      sync_num_o                 => sync_num,
      num_rows_reported_o        => num_rows_to_read,
      num_cols_reported_o        => num_cols_to_read,

      row_switch_o               => open,
      row_en_o                   => open,

      update_bias_o              => open,

      dat_i                      => data,
      addr_i                     => addr,
      tga_i                      => tga,
      we_i                       => we,
      stb_i                      => stb,
      cyc_i                      => cyc,
      dat_o                      => frame_timing_data,
      ack_o                      => frame_timing_ack,

      clk_i                      => clk,
      clk_n_i                    => clk_n,
      rst_i                      => rst,
      sync_i                     => encoded_sync
   );

   dv_rx_slave: dv_rx
   port map(
      -- Clock and Reset:
      clk_i               => clk,
      manch_clk_i         => manch_clk,  -- Manchester Clock Input
      clk_n_i             => clk_n,
      rst_i               => rst,

      -- Fibre Interface
      manch_det_i         => manchester_sigdet,
      manch_dat_i         => manchester_data,
      dv_dat_i            => dv_pulse_fibre,

      -- Issue-Reply Interface:
      dv_mode_i           => dv_mode,
      dv_o                => external_dv,
      dv_sequence_num_o   => external_dv_num,
      sync_box_err_o      => sync_box_err,
      sync_box_err_ack_i  => sync_box_err_ack,
      sync_box_free_run_o => sync_box_free_run,

      sync_mode_i         => sync_mode,
      sync_o              => external_sync
   );

   cards_present <= not card_not_present;
   ret_dat_parameter_slave: ret_dat_wbs
   port map
   (
      -- ret_dat command signals (to cmd_translator)
      start_seq_num_o        => start_seq_num,
      stop_seq_num_o         => stop_seq_num,
      data_rate_o            => data_rate,
      internal_cmd_mode_o    => internal_cmd_mode,
      step_period_o          => step_period,
      step_minimum_o         => step_minimum,
      step_size_o            => step_size,
      step_maximum_o         => step_maximum,
      step_param_id_o        => step_param_id,
      step_card_addr_o       => step_card_addr,
      step_data_num_o        => step_data_num,
      run_file_id_o          => run_file_id,
      user_writable_o        => user_writable,
      stop_delay_o           => stop_delay,
      crc_err_en_o           => crc_err_en,
--      num_rows_to_read_o     => num_rows_to_read,
--      num_cols_to_read_o     => num_cols_to_read,
      ret_dat_req_o          => ret_dat_req,
      ret_dat_ack_i          => ret_dat_done,
      cards_present_i        => cards_present,
      cards_to_report_o      => cards_to_report,
      rcs_to_report_data_o   => rcs_to_report_data,
      awg_dat_o              => awg_dat,   
      awg_addr_o             => awg_addr,
      awg_addr_incr_i        => awg_addr_incr,
      
      -- global interface
      clk_i                  => clk,
      rst_i                  => rst,

      -- wishbone interface:
      dat_i                  => data,
      addr_i                 => addr,
      tga_i                  => tga,
      we_i                   => we,
      stb_i                  => stb,
      cyc_i                  => cyc,
      err_o                  => ret_dat_err,
      dat_o                  => ret_dat_data,
      ack_o                  => ret_dat_ack
   );

   ----------------------------------------------------------------
   -- PSUC Dispatch Block and Slave
   ----------------------------------------------------------------
   -- Wishbone signals
   with psu_addr select
      psu_slave_data <=
         psu_slave_data2 when BRST_MCE_ADDR | CYCLE_POW_ADDR | CUT_POW_ADDR | PSC_STATUS_ADDR,
         (others => '0') when others;

   with psu_addr select
      psu_slave_ack <=
         psu_slave_ack2 when BRST_MCE_ADDR | CYCLE_POW_ADDR | CUT_POW_ADDR | PSC_STATUS_ADDR,
         '0' when others;

   with psu_addr select
      psu_slave_err <=
         psu_slave_err2 when BRST_MCE_ADDR | CYCLE_POW_ADDR | CUT_POW_ADDR | PSC_STATUS_ADDR,
         '1' when others;

   psuc_dispatch_block: dispatch
   port map(
      lvds_cmd_i   => cmd,

      lvds_replya_o => lvds_reply_psu_a,
      lvds_replyb_o => lvds_reply_psu_b,

      --  Global signals
      clk_i        => clk,
      comm_clk_i   => comm_clk,
      rst_i        => rst,

      -- Wishbone interface
      dat_o        => psu_data,
      addr_o       => psu_addr,
      tga_o        => psu_tga,
      we_o         => psu_we,
      stb_o        => psu_stb,
      cyc_o        => psu_cyc,
      dat_i        => psu_slave_data,
      ack_i        => psu_slave_ack,
      err_i        => psu_slave_err,

      wdt_rst_o    => open,
      slot_i       => "1001", -- PSUC
      dip_sw3      => '1',
      dip_sw4      => '1'
   );

   psu_ctrl_slave: psu_ctrl
   port map(
      -- Clock and Reset:
      clk_i   => clk,
      clk_n_i => clk_n,
      rst_i   => rst,

      -- Wishbone Interface:
      dat_i   => psu_data,
      addr_i  => psu_addr,
      tga_i   => psu_tga,
      we_i    => psu_we,
      stb_i   => psu_stb,
      cyc_i   => psu_cyc,
      dat_o   => psu_slave_data2,
      ack_o   => psu_slave_ack2,
      err_o   => psu_slave_err2,

      -- SPI Interface
      mosi_i  => mosii,
      sclk_i  => sclki,
      ccss_i  => ccssi,
      miso_o  => misoo,
      sreq_o  => sreqo
   );

end top;