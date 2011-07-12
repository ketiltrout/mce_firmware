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
-- $Id: clk_card.vhd,v 1.97 2010/05/14 22:38:28 bburger Exp $
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library components;
use components.component_pack.all;

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

      -- miscellaneous ports:
      red_led           : out std_logic;
      ylw_led           : out std_logic;
      grn_led           : out std_logic;
      slot_id           : in std_logic_vector(3 downto 0);

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

      FSE_D : inout std_logic_vector(31 downto 0);

      -- In progress, outputs:
      FSE_A : out std_logic_vector(15 downto 0); -- Address
      ENET_ADS_N : out std_logic; -- Address latch
      ENET_IOR_N : out std_logic; -- Read enable
      ENET_IOW_N : out std_logic; -- Write enable

      -- In progress, inputs:
      -- On reads, if ARDY is not connected to the FPGA, the data register should not be read before 370ns after the pointer was loaded to allow the data register FIFO to fill
      ENET_IOCHRDY : in std_logic; -- AKA: ENET_ARDY
      ENET_INTRQ : in std_logic_vector(0 downto 0); -- Interrupt request
      ENET_LDEV_N : in std_logic; -- 91c111 chip active

      -- Done
      ENET_AEN : out std_logic; -- Address decode enable
      ENET_BE_N : out std_logic_vector(3 downto 0);
      -- ENET_RESET:  On this card is controlled by the configuration CPLD, which is possibly controlled by the MASTER_RESET_n signal trigger by SW10 (Config Reset)

      -- Normally inputs, but tied high when in ansynchronous mode
      ENET_LCLK : out std_logic;
      ENET_W_R_N : out std_logic;
      ENET_CYCLE_N : out std_logic;
      ENET_RDYRTN_N : out std_logic;
      ENET_VLBUS_N : out std_logic;
      ENET_SRDY_N : out std_logic;
      ENET_DATACS_N : out std_logic;

      LEDG : out std_logic_vector(7 downto 0);
      Display_7_Segment : out std_logic_vector(15 downto 0);

      PLD_CLKOUT : in std_logic;
      PLD_RECONFIGREQ_N : in std_logic;

      USER_PB : in std_logic_vector(3 downto 0);

      INIT_DONE : in std_logic;
      PLD_CLKFB : in std_logic;

      TR_CLK : in std_logic
   );
end clk_card;

architecture top of clk_card is

   -- The REVISION format is RRrrBBBB where
   --               RR is the major revision number
   --               rr is the minor revision number
   --               BBBB is the build number
   constant CC_REVISION: std_logic_vector (31 downto 0) := X"05000008";

   -- reset
   signal rst                : std_logic;

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
   signal lvds_reply_cc_b  : std_logic;
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

   signal cc_bclr            : std_logic;    -- reset signal generated by Linux PC issuing a 'special character' byte down the fibre
   signal mce_bclr           : std_logic;
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

   signal awg_dat            : std_logic_vector(AWG_DAT_WIDTH-1 downto 0);
   signal awg_addr           : std_logic_vector(AWG_ADDR_WIDTH-1 downto 0);
   signal awg_addr_incr      : std_logic;

   -----------------------------------------------------
   -- LED and SSD Signals
   -----------------------------------------------------
   type row_states is (IDLE, TOGGLE_VAL);
   signal row_current_state   : row_states;
   signal row_next_state      : row_states;
   signal timer_clr           : std_logic;
   signal timer_count         : integer;
   signal red_led_sig         : std_logic := '1';

   -- Seven Segment Display Characters
   constant BEE      : std_logic_vector(7 downto 0) := "00011111";
   constant SS_ZERO  : std_logic_vector(7 downto 0) := "01111110";
   constant SS_ONE   : std_logic_vector(7 downto 0) := "00110000";
   constant SS_TWO   : std_logic_vector(7 downto 0) := "01101101";
   constant SS_THREE : std_logic_vector(7 downto 0) := "01111001";
   constant SS_FOUR  : std_logic_vector(7 downto 0) := "00110011";
   constant SS_FIVE  : std_logic_vector(7 downto 0) := "01011011";
   constant SS_SIX   : std_logic_vector(7 downto 0) := "01001111";
   constant SS_SEVEN : std_logic_vector(7 downto 0) := "01110000";
   constant SS_EIGHT : std_logic_vector(7 downto 0) := "01111111";
   constant SS_NINE  : std_logic_vector(7 downto 0) := "01110011";

   -----------------------------------------------------
   -- Access Constants
   -----------------------------------------------------
   -- On page 61 of the LAN91C111 datasheet, it states:
   -- "On reads, if ARDY is not connected to the host, the Data Register should not be read before 370ns after the pointer was loaded to allow the Data Register FIFO to fill"
   -- This relates only to pointer-driven accesses.  In practice, I've noticed that all other accesses take 2 cycles from the moment that NRD/NRW are asserted.
   -- The number of wait states actually ends up being ACCESS_TIME+2, because it takes one cycle to assert NRD/NRW, and one cycle to exit the WAIT_FOR_ARDY state.
   -- This means that the actual time waited is 4 cycles; 2 more than is necessary.
   constant REG_DATA_WIDTH        : integer := 16;
   constant REG_ADDR_WIDTH        : integer := 3;
   constant BANK_ADDR_WIDTH       : integer := 2;
   constant PACKET_NUM_WIDTH      : integer := 6;

   constant ACCESS_TIME           : integer := 2;
--   constant ACCESS_TIME           : integer := 20;
   constant ACCESS_TIME_W_POINTER : integer := 20;

   -- Read/Write constants
   constant READ             : std_logic := '0';
   constant WRITE            : std_logic := '1';

   -----------------------------------------------------
   -- MII Command Codes
   -----------------------------------------------------
   -- Idle pattern: = 11111111111111111111111111111111
   -- S: Start bits = 01
   -- R: Read = 10, Write = 01
   -- pADR: Physical Address
   -- rADR: Register Address
   -- T: Turnaround time.  Read = Z0, Write = 10
   -- Data: 16 bits of data to/from on of the eleven registers.
   --                                              /-----------Idle Pattern--------/S/R/pADR/rADR/T/----Data------/
   --constant MII_READ_REGS : std_logic_vector() := "111111111111111111111111111111110110";


   -----------------------------------------------------
   -- 91C111 Bank and Register Addresses
   -----------------------------------------------------
   -- Bank Selection
   constant BANK0_ADDR       : std_logic_vector(BANK_ADDR_WIDTH-1 downto 0) := "00";
   constant BANK1_ADDR       : std_logic_vector(BANK_ADDR_WIDTH-1 downto 0) := "01";
   constant BANK2_ADDR       : std_logic_vector(BANK_ADDR_WIDTH-1 downto 0) := "10";
   constant BANK3_ADDR       : std_logic_vector(BANK_ADDR_WIDTH-1 downto 0) := "11";

   -- Global Bank Register
   constant BANK_SELECT_ADDR : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "111";
   constant FIRST_REG_ADDR   : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "000";
   constant LAST_REG_ADDR    : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "110";

   -- MMU Command Codes
   constant NOOP_CMD                               : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000000000000";
   constant ALLOCATE_MEMORY_FOR_TX_CMD             : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000000100000";
   constant RESET_MMU_TO_INITIAL_STATE_CMD         : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000001000000";
   constant REMOVE_FRAME_FROM_TOP_OF_RX_FIFO_CMD   : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000001100000";
   constant REMOVE_AND_RELEASE_TOP_OF_RX_FIFO_CMD  : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000010000000";
   constant RELEASE_SPECIFIC_PACKET_CMD            : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000010100000";
   constant ENQUEUE_PACKET_NUMBER_INTO_TX_FIFO_CMD : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000011000000";
   constant RESET_TX_FIFOS_CMD                     : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000011100000";

   -- Data Bit Masks
   constant BITMASK_TXENA          : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000000000001"; -- bank 0, reg 0, bit 0
   constant BITMASK_AUTO_RELEASE   : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000100000000000"; -- bank 1, reg 6, bit 11

   -- Pointer Register Configurations (Auto-Increment = OFF)
   constant POINTER_REG_TX         : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0000000000000000"; -- bank 2, reg 3
   constant POINTER_REG_TX_READ    : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "0010000000000000"; -- bank 2, reg 3
   constant POINTER_REG_RX         : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "1000000000000000"; -- bank 2, reg 3
   constant POINTER_REG_RX_READ    : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := "1010000000000000"; -- bank 2, reg 3

   -- Control Bit Indexes
   constant ALLOCATION_RES_BIT : integer := 7;  -- bank 2, reg 1
   constant ALLOC_BIT          : integer := 11; -- bank 2, reg 6
   constant NOT_EMPTY_BIT      : integer := 11; -- bank 2, reg 3

   -- Register Integer Indexes: for accessing FPGA stored values in the register bank
   constant TCR_ADDR_INT       : integer := 0;  -- bank 0, reg 0
   constant CONTROL_ADDR_INT   : integer := 14; -- bank 1, reg 6
   constant INTERRUPT_ADDR_INT : integer := 22; -- bank 2, reg 6
   constant PNR_ADDR_INT       : integer := 17; -- bank 2, reg 1
   constant POINTER_ADDR_INT   : integer := 19; -- bank 2, reg 3

   -- Register Addresses
   -- Default values are as read by SignalTap; they don't necessarily agree with datasheet
   -- Bank 0 Registers                                                                  Default Values
   constant TCR_ADDR         : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "000"; -- 0x0000
   constant EPH_STATUS_ADDR  : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "001"; -- 0x0000
   constant RCR_ADDR         : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "010"; -- 0x0000
   constant COUNTER_ADDR     : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "011"; -- 0x0000
   constant MIR_ADDR         : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "100"; -- 0x0404
   constant RPCR_ADDR        : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "101"; -- 0x08DC
   constant RESERVED_ADDR    : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "110"; -- 0x0000 don't care

   -- Bank 1 Registers                                                                  Default Values
   constant CONFIG_ADDR      : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "000"; -- 0xA0B1
   constant BASE_ADDR        : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "001"; -- 0x1801
   constant IA0_1_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "010"; -- 0x0700
   constant IA2_3_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "011"; -- 0x0AED
   constant IA4_5_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "100"; -- 0xF1A4
   constant GEN_PURPOSE_ADDR : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "101"; -- 0x0000
   constant CONTROL_ADDR     : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "110"; -- 0x1210

   -- Bank 2 Registers                                                                  Default Values
   constant MMU_COMMAND_ADDR : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "000"; -- 0x3332
   constant PNR_ADDR         : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "001"; -- 0x8000
   constant FIFO_PORTS_ADDR  : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "010"; -- 0x8080
   constant POINTER_ADDR     : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "011"; -- 0x0008
   constant DATA0_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "100"; -- 0x0080
   constant DATA1_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "101"; -- 0x0080
   constant INTERRUPT_ADDR   : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "110"; -- 0x0004

   -- Bank 3 Registers                                                                  Default Values
   constant MT0_1_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "000"; -- 0x0000
   constant MT2_3_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "001"; -- 0x0000
   constant MT4_5_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "010"; -- 0x0000
   constant MT6_7_ADDR       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "011"; -- 0x0000
   constant MGMT_ADDR        : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "100"; -- 0x3330
   constant REVISION_ADDR    : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "101"; -- 0x3391
   constant RCV_ADDR         : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := "110"; -- 0x001F

   -- Sample Packet
   -- Make a shortened subroutine for loading this..
   --00 00 01 1C    # Status word and byte count
   --00 01 02 03    # Dest
   --04 05 10 11    #  and
   --12 13 14 15    #   source MACs
   --0A 0B 00 02    # Ethernet ID and MCEoE packet type
   --0C 0D 0E 0F    # Transaction ID
   --4B 4F 42 57    # Reply data (note switch to little-endian)
   --30 00 04 00    # ...
   --00 09 00 00    # ...
   --7B 46 46 57    # ...
   --00 00 00 00    # Padding begins.
   -- (repeat 59 more times)
   --00 00 00 00    # CRC and control byte and odd data byte.

   -- Sample Packet
   constant SAMPLE_PACKET_SIZE : integer := 142;  -- make this assignement an calculation in the final version
   constant BYTE_000 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0000";
   constant BYTE_001 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"011C";
   constant BYTE_002 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0001";
   constant BYTE_003 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0203";
   constant BYTE_004 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0405";
   constant BYTE_005 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"1011";
   constant BYTE_006 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"1213";
   constant BYTE_007 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"1415";
   constant BYTE_008 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0A0B";
   constant BYTE_009 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0002";
   constant BYTE_010 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0C0D";
   constant BYTE_011 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0E0F";
   constant BYTE_012 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"4B4F";
   constant BYTE_013 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"4257";
   constant BYTE_014 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"3000";
   constant BYTE_015 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0400";
   constant BYTE_016 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0009";
   constant BYTE_017 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0000";
   constant BYTE_018 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"7B46";
   constant BYTE_019 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"4657";
   constant BYTE_020_TO_139 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0000"; -- Data payload
   constant BYTE_140 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0000";
   constant BYTE_141 : std_logic_vector(REG_DATA_WIDTH-1 downto 0) := x"0000";

   -----------------------------------------------------
   -- 91C111 FSM Signals
   -----------------------------------------------------
   type states is (
      -- Register scan states
      IDLE, ASSERT_ADDR, ASSERT_NADS, ASSERT_NRD_NWR, WAIT_FOR_ARDY, LATCH_DATA, NEXT_ADDR,
      -- Utility states
      PAUSE, DEBOUNCE_BUTTON0, DEBOUNCE_BUTTON1, DEBOUNCE_BUTTON2, MII_PREP, DEBOUNCE_BUTTON3,
      -- Packet TX states
      SET_AUTO_RELEASE_BIT, SET_TXENA_BIT, ALLOC_TX_MEM, ALLOC_WAIT, ALLOC_RESULT_REG_READ, WRITE_TX_PACKET_NUMBER, CHECK_NOT_EMPTY, READ_POINTER_REG, SET_POINTER_REG, LOAD_TX_DATA, WRITE_POINTER_REG, ENQUEUE_PACKET,
      -- Generalized read/write states
      W_BANK_ASSERT_ADDR, W_BANK_ASSERT_NADS, W_BANK_ASSERT_NRD_NWR, W_BANK_WAIT_FOR_ARDY, W_TO_RW_TRANSITION, RW_ASSERT_ADDR, RW_ASSERT_NADS, RW_ASSERT_NRD_NWR, RW_WAIT_FOR_ARDY, RW_LATCH_DATA, DETERMINE_NEXT_STATE
   );
   signal current_state : states;
   signal next_state    : states;

   -- Register bank signals
   signal reg_wren_vec    : w1_array32;
   signal reg_data_vec    : w16_array32;
   signal sev_seg         : std_logic_vector(15 downto 0);

   -- Various counter signals
   signal reg_count       : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
   signal reg_count_next  : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
   signal reg_count_ena   : std_logic;

   signal bank_count      : std_logic_vector(BANK_ADDR_WIDTH-1 downto 0);
   signal bank_count_next : std_logic_vector(BANK_ADDR_WIDTH-1 downto 0);
   signal bank_count_ena  : std_logic;

   signal cyc_count       : integer; -- range?
   signal cyc_count_next  : integer;
   signal cyc_count_ena   : std_logic;

   signal bit_count       : integer;
   signal bit_count_next  : integer;
   signal bit_count_ena   : std_logic;

   signal byte_count      : integer;
   signal byte_count_next : integer;
   signal byte_count_ena  : std_logic;
   signal byte_count_clr  : std_logic;
--   signal byte_count_ld   : std_logic;
   signal byte_count_slv  : std_logic_vector(10 downto 0);
   signal byte_count_plus_offset : std_logic_vector(10 downto 0);

   signal reg_num_slv     : std_logic_vector(4 downto 0);
   signal reg_num_int     : integer; -- range?

   -- For single-access subroutine
   signal sa_reg_num_slv  : std_logic_vector(4 downto 0);
   signal sa_reg_num_int  : integer; -- range?

   signal action_reg_wren : std_logic;
   signal action_reg_clr  : std_logic;
   signal read_nwrite     : std_logic;
   signal bank_addr       : std_logic_vector(1 downto 0);
   signal reg_addr        : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
   signal reg_data        : std_logic_vector(15 downto 0);
   signal source_state    : states;
   signal read_nwrite_reg : std_logic;
   signal bank_addr_reg   : std_logic_vector(1 downto 0);
   signal reg_addr_reg    : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
   signal reg_data_reg    : std_logic_vector(15 downto 0);
   signal source_state_reg : states;


begin

   -----------------------------------------------------
   -- LED signals
   -----------------------------------------------------
   LEDG(7) <= ENET_INTRQ(0);
   LEDG(6) <= '0';
   LEDG(5) <= '0';
   LEDG(4) <= '0';
   LEDG(3) <= '0';
   red_led <= reg_data_vec(PNR_ADDR_INT)(ALLOCATION_RES_BIT);
   ylw_led <= not ENET_LDEV_N; -- Show if the LAN91C111 is bus-selected or not.  LED is on if selected.
   grn_led <= red_led_sig;

   Display_7_Segment <= not sev_seg;
   -- Query register banks
   sev_seg(15 downto 8) <= SS_ONE when USER_PB(0) = '0' else SS_ZERO;
   -- Send a packet
   sev_seg(7  downto 0) <= SS_ONE when USER_PB(1) = '0' else SS_ZERO;

   -----------------------------------------------------
   -- LAN91C111 Static Control Lines
   -----------------------------------------------------
   -- Disable synchronous mode
   ENET_LCLK     <= '1';
   ENET_W_R_N    <= '1';
   ENET_CYCLE_N  <= '1';
   ENET_RDYRTN_N <= '1';
   ENET_VLBUS_N  <= '1';
   ENET_SRDY_N   <= '1';
   ENET_DATACS_N <= '1'; -- Disable direct access to the data path, i.e. for 32-bit bursting

   -- Address decode always enabled, i.e. chip always selected
   ENET_AEN   <= '0';

   -- Enable the LAN91C111's default bus address
   FSE_A( 0) <= '0';
   --FSE_A( 1) <= '0'; -- This is for register selection
   --FSE_A( 2) <= '0'; -- This is for register selection
   --FSE_A( 3) <= '0'; -- This is for register selection
   FSE_A( 4) <= '0';
   FSE_A( 5) <= '0';
   FSE_A( 6) <= '0';
   FSE_A( 7) <= '0';
   FSE_A( 8) <= '1';
   FSE_A( 9) <= '1';
   FSE_A(10) <= '0';
   FSE_A(11) <= '0';
   FSE_A(12) <= '0';
   FSE_A(13) <= '0';
   FSE_A(14) <= '0';
   FSE_A(15) <= '0';

   -- Width of data bus = lower 16 bits
   ENET_BE_N <= "1100";

   -----------------------------------------------------
   -- LAN91C111 FSM and Logic
   -----------------------------------------------------
   byte_count_slv <= conv_std_logic_vector(byte_count,11);
   byte_count_plus_offset <= byte_count_slv + reg_data_vec(POINTER_ADDR_INT)(10 downto 0);

   sa_reg_num_slv <= bank_addr_reg & reg_addr_reg;
   sa_reg_num_int <= conv_integer(sa_reg_num_slv);

   reg_num_slv <= bank_count & reg_count;
   reg_num_int <= conv_integer(reg_num_slv);

   -- Storage for 4 x 8 = 32 16-bit 91C111 registers
   reg_bank: for i in 0 to 31 generate
      registers : reg
      generic map(WIDTH => 16)
      port map(
         clk_i  => clk,
         rst_i  => rst,
         ena_i  => reg_wren_vec(i),
         reg_i  => FSE_D(15 downto 0),
         reg_o  => reg_data_vec(i)
      );
   end generate reg_bank;

   -- The address of the register being accessed during a block read.  Range = 000..111
   reg_count_next <= reg_count + 1;
   reg_counter: process(clk, rst)
   begin
      if(rst = '1') then
         reg_count <= FIRST_REG_ADDR;
      elsif(clk'event and clk = '1') then
         if(reg_count_ena = '1') then
            reg_count <= reg_count_next;
         end if;
      end if;
   end process reg_counter;

   -- The index of the bank being addressed during a block read.  Range = 00..11.
   bank_count_next <= bank_count + 1;
   bank_counter: process(clk, rst)
   begin
      if(rst = '1') then
         bank_count <= BANK0_ADDR;
      elsif(clk'event and clk = '1') then
         if(bank_count_ena = '1') then
            bank_count <= bank_count_next;
         end if;
      end if;
   end process bank_counter;

   -- The index of the data byte to write to block memory
   byte_count_next <= byte_count + 1;
   byte_counter: process(clk, rst)
   begin
      if(rst = '1') then
         byte_count <= 0;
      elsif(clk'event and clk = '1') then
         if(byte_count_ena = '1') then
            byte_count <= byte_count_next;
--         elsif(byte_count_ld = '1') then
--            byte_count <= reg_data_vec(POINTER_ADDR_INT)(10 downto 0);  -- Load the pointer given
         elsif(byte_count_clr = '1') then
            byte_count <= 0;
         end if;
      end if;
   end process byte_counter;

   -- The index of the MII bit being quieried.
   bit_count_next <= bit_count + 1;
   bit_counter: process(clk, rst)
   begin
      if(rst = '1') then
         bit_count <= 0;
      elsif(clk'event and clk = '1') then
         if(bit_count_ena = '1') then
            bit_count <= bit_count_next;
         end if;
      end if;
   end process bit_counter;

   -- A clock counter for measuring the access time before the data for a particular register becomes valid
   cyc_count_next <= cyc_count + 1;
   wait_timer: process(clk, rst)
   begin
      if(rst = '1') then
         cyc_count <= 0;
      elsif(clk'event and clk = '1') then
         if(cyc_count_ena = '1') then
            cyc_count <= cyc_count_next;
         else
            cyc_count <= 0;
         end if;
      end if;
   end process wait_timer;

   action_regs: process(clk, rst)
   begin
      if(rst = '1') then
         read_nwrite_reg  <= '0';
         bank_addr_reg    <= (others => '0');
         reg_addr_reg     <= (others => '0');
         reg_data_reg     <= (others => '0');
         source_state_reg <= IDLE;
      elsif(clk'event and clk = '1') then
         if(action_reg_wren = '1') then
            read_nwrite_reg  <= read_nwrite;
            bank_addr_reg    <= bank_addr;
            reg_addr_reg     <= reg_addr;
            reg_data_reg     <= reg_data;
            source_state_reg <= source_state;
         elsif(action_reg_clr = '1') then
            read_nwrite_reg  <= '0';
            bank_addr_reg    <= (others => '0');
            reg_addr_reg     <= (others => '0');
            reg_data_reg     <= (others => '0');
            source_state_reg <= IDLE;
         end if;
      end if;
   end process action_regs;

   state_NS: process(current_state, cyc_count, reg_count, bank_count, USER_PB, source_state_reg, reg_data_vec, byte_count)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         when IDLE =>
            -- IDLE is an interesting state, because it is the beginning of a cycle through all the 91C111 registers
            next_state <= ASSERT_NADS;

         -----------------------------------------------------
         -- Query and store all register values
         -----------------------------------------------------
         when ASSERT_NADS =>
            next_state <= ASSERT_ADDR;

         when ASSERT_ADDR =>
            next_state <= ASSERT_NRD_NWR;

         when ASSERT_NRD_NWR =>
            next_state <= WAIT_FOR_ARDY;

         when WAIT_FOR_ARDY =>
            -- There is an error on the Altera Stratix I Development Board that prevents me from using the ARDY signal for register accesses.
            -- This signal is an open-drain output from the 91C111, which requires a weak pull-up resistor on this line, but there is not.
            -- On reads, if ARDY is not connected to the host, the Data Register should not be read before 370ns (= 18.5 clock cycles) after the pointer was loaded for EEPROM access
            -- Normal access only require ~4 clock cycles.
            --if(ENET_IOCHRDY = '1') then
            if(cyc_count = ACCESS_TIME) then
               next_state <= LATCH_DATA;
            end if;

         when LATCH_DATA =>
            next_state <= NEXT_ADDR;

         when NEXT_ADDR =>
            -- If we've queried all the registers, then
            if(reg_count = LAST_REG_ADDR and bank_count = BANK3_ADDR) then
               -- Enter the PAUSE state
               next_state <= PAUSE;
            else
               -- Keep on cycling through the registers
               next_state <= IDLE;
            end if;

         -----------------------------------------------------
         -- Wait for directives.
         -- This will be the state that I monitor IRQs in.
         -----------------------------------------------------
         when PAUSE =>
            -- This is the master-state from which we query registers, and send/receive packets
            -- If I push a button, it grounds the I/O pin to the FPGA
            if(USER_PB(0) = '0') then
               next_state <= DEBOUNCE_BUTTON0;
            elsif(USER_PB(1) = '0') then
               next_state <= DEBOUNCE_BUTTON1;
            elsif(USER_PB(2) = '0') then
               next_state <= DEBOUNCE_BUTTON2;
            elsif(USER_PB(3) = '0') then
               next_state <= DEBOUNCE_BUTTON3;
            end if;

         when DEBOUNCE_BUTTON0 =>
            if(USER_PB(0) = '1') then
               -- Read all 91C111 registers, and store them
               next_state <= IDLE;
            end if;

         when DEBOUNCE_BUTTON1 =>
            if(USER_PB(1) = '1') then
               -- Read MIR register
               next_state <= W_BANK_ASSERT_NADS;
            end if;

         when DEBOUNCE_BUTTON2 =>
            if(USER_PB(2) = '1') then
               -- Read MII register
               next_state <= MII_PREP;
            end if;

         when MII_PREP =>
            next_state <= W_BANK_ASSERT_NADS;

         when DEBOUNCE_BUTTON3 =>
            if(USER_PB(3) = '1') then
               -- TX Packet
               next_state <= SET_AUTO_RELEASE_BIT;
            end if;

         -----------------------------------------------------
         -- 91C111 generalized single-register read/write subroutine
         -----------------------------------------------------
         when W_BANK_ASSERT_NADS =>
            next_state <= W_BANK_ASSERT_ADDR;

         when W_BANK_ASSERT_ADDR =>
            next_state <= W_BANK_ASSERT_NRD_NWR;

         when W_BANK_ASSERT_NRD_NWR =>
            next_state <= W_BANK_WAIT_FOR_ARDY;

         when W_BANK_WAIT_FOR_ARDY =>
            if(cyc_count = ACCESS_TIME) then
               next_state <= W_TO_RW_TRANSITION;
            end if;

         when W_TO_RW_TRANSITION =>
            next_state <= RW_ASSERT_NADS;

         when RW_ASSERT_NADS =>
            next_state <= RW_ASSERT_ADDR;

         when RW_ASSERT_ADDR =>
            next_state <= RW_ASSERT_NRD_NWR;

         when RW_ASSERT_NRD_NWR =>
            next_state <= RW_WAIT_FOR_ARDY;

         when RW_WAIT_FOR_ARDY =>
            -- If we are loading data into the pipelined SRAM, we need more time
--            if(source_state = LOAD_TX_DATA) then
--               if(cyc_count = ACCESS_TIME_W_POINTER) then
--                  next_state <= RW_LATCH_DATA;
--               end if;
--            else
               if(cyc_count = ACCESS_TIME) then
                  next_state <= RW_LATCH_DATA;
               end if;
--            end if;

         when RW_LATCH_DATA =>
            next_state <= DETERMINE_NEXT_STATE;

         when DETERMINE_NEXT_STATE =>
            -- Register Query
            if(source_state_reg = PAUSE) then
               next_state <= PAUSE;

            -- TX Packet
            elsif(source_state_reg = SET_AUTO_RELEASE_BIT) then
               next_state <= SET_TXENA_BIT;
            elsif(source_state_reg = SET_TXENA_BIT) then
               next_state <= ALLOC_TX_MEM;
            elsif(source_state_reg = ALLOC_TX_MEM) then
               next_state <= ALLOC_WAIT;
            elsif(source_state_reg = ALLOC_WAIT) then
               -- Try reading the PNR register, because it will have the packet number
               if(reg_data_vec(PNR_ADDR_INT)(ALLOCATION_RES_BIT) = '1') then -- Set when an MMU request for TX RAM pages is successful
--               if(reg_data_vec(INTERRUPT_ADDR_INT)(ALLOC_BIT) = '0') then -- Set when an MMU request for TX RAM pages is successful
                  -- If the allocation was successful, keep polling the allocation interrupt register until it is acknowldged
                  next_state <= ALLOC_WAIT;
               else
                  -- Load the packet date
                  next_state <= ALLOC_RESULT_REG_READ;
               end if;
            elsif(source_state_reg = ALLOC_RESULT_REG_READ) then
               next_state <= WRITE_TX_PACKET_NUMBER;
            elsif(source_state_reg = WRITE_TX_PACKET_NUMBER) then
               next_state <= CHECK_NOT_EMPTY;
            elsif(source_state_reg = CHECK_NOT_EMPTY) then
               if(reg_data_vec(POINTER_ADDR_INT)(NOT_EMPTY_BIT) = '1') then
                  -- Wait until empty
                  next_state <= CHECK_NOT_EMPTY;
               else
                  -- SRAM pipeline is empty
                  next_state <= READ_POINTER_REG;
               end if;
            elsif(source_state_reg = READ_POINTER_REG) then
               next_state <= SET_POINTER_REG;
            elsif(source_state_reg = SET_POINTER_REG) then
               next_state <= LOAD_TX_DATA;
            elsif(source_state_reg = LOAD_TX_DATA) then
               next_state <= WRITE_POINTER_REG;
            elsif(source_state_reg = WRITE_POINTER_REG) then
               if(byte_count = SAMPLE_PACKET_SIZE-1) then
                  -- We've loaded the whole packet
                  next_state <= ENQUEUE_PACKET;
               else
                  next_state <= LOAD_TX_DATA;
               end if;
            elsif(source_state_reg = ENQUEUE_PACKET) then
               next_state <= PAUSE;

            -- RX Packet
            end if;

         -----------------------------------------------------
         -- TX Packet: each one of these states involves a read or a write using the 91C111 generalized single-register read/write subroutine, above.
         -----------------------------------------------------
         when SET_AUTO_RELEASE_BIT
            | SET_TXENA_BIT
            | ALLOC_TX_MEM
            | ALLOC_WAIT
            | ALLOC_RESULT_REG_READ
            | WRITE_TX_PACKET_NUMBER -- What is this??
            | CHECK_NOT_EMPTY
            | READ_POINTER_REG
            | SET_POINTER_REG
            | LOAD_TX_DATA
            | WRITE_POINTER_REG
            | ENQUEUE_PACKET =>
            next_state <= W_BANK_ASSERT_NADS;

         -----------------------------------------------------
         -- RX Packet
         -----------------------------------------------------
         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   state_out: process(current_state, reg_count, bank_count, reg_num_int, bank_addr_reg, reg_addr_reg, read_nwrite_reg, reg_data_reg, reg_data_vec, sa_reg_num_int, USER_PB, byte_count, byte_count_plus_offset)
   begin
      -- Default assignments
      FSE_A(3 downto 1) <= reg_count; -- Register address
      FSE_D <= (others => 'Z');

      ENET_ADS_N <= '1';
      ENET_IOR_N <= '1';
      ENET_IOW_N <= '1';
      --bank_reg_wren <= '0';
      reg_wren_vec <= (others => '0');
      reg_count_ena <= '0';
      cyc_count_ena <= '0';
      bank_count_ena <= '0';
      bit_count_ena <= '0';
      byte_count_ena <= '0';
      byte_count_clr <= '0';
--      byte_count_ld <= '0';

      -- Values to determine what sort of register access is going to happen
      action_reg_wren <= '0';
      action_reg_clr  <= '0';
      read_nwrite     <= '0';
      bank_addr       <= (others => '0');
      reg_addr        <= (others => '0');
      reg_data        <= (others => '0');
      source_state    <= IDLE;

      case current_state is
         when IDLE =>

         -----------------------------------------------------
         -- Query and store all register values
         -----------------------------------------------------
         when ASSERT_NADS =>
            -- If we are at the last register address in a bank then..
            if(reg_count = BANK_SELECT_ADDR) then
               -- Increment the bank address too
               bank_count_ena <= '1';
            end if;
            ENET_ADS_N <= '0';

         when ASSERT_ADDR =>
            -- If we are at the last register address in a bank then..
            if(reg_count = BANK_SELECT_ADDR) then
               -- Assert a new bank address on the data bus
               -- Note:  the third bit of the data bus designates "user-registers" that I could access if I wanted to.  I don't want to.
               FSE_D(2 downto 0) <= '0' & bank_count;
            end if;
            ENET_ADS_N <= '0';

         when ASSERT_NRD_NWR =>
            -- If we are at the last register address in a bank then..
            if(reg_count = BANK_SELECT_ADDR) then
               FSE_D(2 downto 0) <= '0' & bank_count;
               -- Write a new bank address
               ENET_IOW_N <= '0';
            end if;
            ENET_ADS_N <= '0';
            ENET_IOR_N <= '0';

         when WAIT_FOR_ARDY =>
            cyc_count_ena <= '1';
            if(reg_count = BANK_SELECT_ADDR) then
               FSE_D(2 downto 0) <= '0' & bank_count;
               ENET_IOW_N <= '0';
            end if;
            ENET_ADS_N <= '0';
            ENET_IOR_N <= '0';

         when LATCH_DATA =>
            reg_wren_vec(reg_num_int) <= '1';
            if(reg_count = BANK_SELECT_ADDR) then
               FSE_D(2 downto 0) <= '0' & bank_count;
               ENET_IOW_N <= '0';
            end if;
            ENET_ADS_N <= '0';
            ENET_IOR_N <= '0';

         when NEXT_ADDR =>
            reg_count_ena <= '1';

         -----------------------------------------------------
         -- Wait for directives.  This will be the state that I monitor IRQs in.
         -----------------------------------------------------
         when PAUSE =>

         -----------------------------------------------------
         -- Latch command directives from buttons
         -----------------------------------------------------
         when DEBOUNCE_BUTTON0 =>
               -- Nothing special to latch here because we are going to read all the registers
               read_nwrite     <= READ;
               bank_addr       <= BANK0_ADDR;
               reg_addr        <= FIRST_REG_ADDR;
               reg_data        <= (others => 'Z');
               source_state    <= PAUSE;
               action_reg_wren <= '1';

         when DEBOUNCE_BUTTON1 =>
               read_nwrite     <= READ;  -- Read
               bank_addr       <= BANK0_ADDR;  -- Bank 0
               reg_addr        <= MIR_ADDR;  -- Memory Information Register
               reg_data        <= (others => 'Z');  -- No data
               source_state    <= PAUSE;  -- Requested from the PAUSE state
               action_reg_wren <= '1';  -- Store these values

         when DEBOUNCE_BUTTON2 =>
            if(USER_PB(2) = '1') then
               -- Figure out what the next bit operation is
               bit_count_ena <= '1';
            end if;

         when MII_PREP =>
--               read_nwrite     <= READ;
--               bank_addr       <= BANK2_ADDR;
--               reg_addr        <= INTERRUPT_ADDR;
--               reg_data        <= (others => 'Z');
--               source_state    <= PAUSE;
--               action_reg_wren <= '1';

         when DEBOUNCE_BUTTON3 =>
               -- Transmit packet
               -- Don't latch anything here.  Do the latching in the dedicated TX states.

         -----------------------------------------------------
         -- 91C111 generalized single-register read/write subroutine
         -----------------------------------------------------
         when W_BANK_ASSERT_NADS =>
            ENET_ADS_N <= '0';
            FSE_A(3 downto 1) <= BANK_SELECT_ADDR;

         when W_BANK_ASSERT_ADDR =>
            ENET_ADS_N <= '0';
            FSE_A(3 downto 1) <= BANK_SELECT_ADDR;
            FSE_D(2 downto 0) <= '0' & bank_addr_reg;

         when W_BANK_ASSERT_NRD_NWR =>
            -- Write a new bank address
            ENET_ADS_N <= '0';
            ENET_IOR_N <= '0';
            ENET_IOW_N <= '0';
            FSE_A(3 downto 1) <= BANK_SELECT_ADDR;
            FSE_D(2 downto 0) <= '0' & bank_addr_reg;

         when W_BANK_WAIT_FOR_ARDY =>
            ENET_ADS_N <= '0';
            ENET_IOR_N <= '0';
            ENET_IOW_N <= '0';
            FSE_A(3 downto 1) <= BANK_SELECT_ADDR;
            FSE_D(2 downto 0) <= '0' & bank_addr_reg;

            cyc_count_ena <= '1';

         when W_TO_RW_TRANSITION =>

         when RW_ASSERT_NADS =>
            ENET_ADS_N <= '0';
            FSE_A(3 downto 1) <= reg_addr_reg;

         when RW_ASSERT_ADDR =>
            ENET_ADS_N <= '0';
            FSE_A(3 downto 1) <= reg_addr_reg;
            if(read_nwrite_reg = '0') then
               FSE_D <= (others => 'Z');
            else
               FSE_D(15 downto 0) <= reg_data_reg;
            end if;

         when RW_ASSERT_NRD_NWR =>
            -- Write a new bank address
            ENET_ADS_N <= '0';
            -- Read all the time
--            ENET_IOR_N <= read_nwrite_reg;
            ENET_IOR_N <= '0';
            ENET_IOW_N <= not read_nwrite_reg;
            FSE_A(3 downto 1) <= reg_addr_reg;
            if(read_nwrite_reg = '0') then
               FSE_D <= (others => 'Z');
            else
               FSE_D(15 downto 0) <= reg_data_reg;
            end if;

         when RW_WAIT_FOR_ARDY =>
            ENET_ADS_N <= '0';
            -- Read all the time
--            ENET_IOR_N <= read_nwrite_reg;
            ENET_IOR_N <= '0';
            ENET_IOW_N <= not read_nwrite_reg;
            FSE_A(3 downto 1) <= reg_addr_reg;
            if(read_nwrite_reg = '0') then
               FSE_D <= (others => 'Z');
            else
               FSE_D(15 downto 0) <= reg_data_reg;
            end if;

            cyc_count_ena <= '1';

         when RW_LATCH_DATA =>
            ENET_ADS_N <= '0';
            -- Read all the time
--            ENET_IOR_N <= read_nwrite_reg;
            ENET_IOR_N <= '0';
            ENET_IOW_N <= not read_nwrite_reg;
            FSE_A(3 downto 1) <= reg_addr_reg;
            if(read_nwrite_reg = '0') then
               FSE_D <= (others => 'Z');
               -- Store the register value if we are reading
               reg_wren_vec(sa_reg_num_int) <= '1';
            else
               FSE_D(15 downto 0) <= reg_data_reg;
            end if;

         when DETERMINE_NEXT_STATE =>
            -- Don't need to latch anything here..
            -- The command latching is done in the state that we forward on to.

         -----------------------------------------------------
         -- TX Setup: things that only need doing once per power-up/ packet
         -- Currently, these things are done for every packet.
         -----------------------------------------------------
         -- Set Auto-Release bit? Bank 1, reg 6.  Is it set by default?  No.  It is bit 11 in CONTROL_ADDR.
         when SET_AUTO_RELEASE_BIT =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK1_ADDR;
            reg_addr        <= CONTROL_ADDR;
            reg_data        <= reg_data_vec(CONTROL_ADDR_INT) or BITMASK_AUTO_RELEASE;
            source_state    <= SET_AUTO_RELEASE_BIT;
            action_reg_wren <= '1';

         when SET_TXENA_BIT =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK0_ADDR;
            reg_addr        <= TCR_ADDR;
            reg_data        <= reg_data_vec(TCR_ADDR_INT) or BITMASK_TXENA;
            source_state    <= SET_TXENA_BIT;
            action_reg_wren <= '1';

         -----------------------------------------------------
         -- TX Packet
         -----------------------------------------------------
         -- Allocate TX packet memory
         when ALLOC_TX_MEM =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= MMU_COMMAND_ADDR;
            reg_data        <= ALLOCATE_MEMORY_FOR_TX_CMD;
            source_state    <= ALLOC_TX_MEM;  -- Must be the same as this state
            action_reg_wren <= '1';

         -- Poll the alloc_int bit until set, i.e. interrupt status register  (bank 2, reg 6, bit 11)
         when ALLOC_WAIT =>
            read_nwrite     <= READ;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= PNR_ADDR;
            reg_data        <= (others => 'Z');
            source_state    <= ALLOC_WAIT;  -- Must be the same as this state
            action_reg_wren <= '1';

            -- If we wait for the interrupt, we must enable the bit mask?!
            -- If we read directly from the MMU register, we don't need to wait for the interrupt.
            -- Figure out what the default value of the interrupt mask is, and use it if I want to.
            -- How do you clear an interrupt?
            -- The datasheet recommends reading the interrupt, because it is synchronous with the clock
--            read_nwrite     <= READ;
--            bank_addr       <= BANK2_ADDR;
--            reg_addr        <= INTERRUPT_ADDR;
--            reg_data        <= (others => 'Z');
--            source_state    <= ALLOC_WAIT;  -- Must be the same as this state
--            action_reg_wren <= '1';

         -- Read allocation result register (bank 2, reg 1).  This yields the TX packet number.
         when ALLOC_RESULT_REG_READ =>
            read_nwrite     <= READ;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= PNR_ADDR;
            reg_data        <= (others => 'Z');
            source_state    <= ALLOC_RESULT_REG_READ;  -- Must be the same as this state
            action_reg_wren <= '1';

         when WRITE_TX_PACKET_NUMBER =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= PNR_ADDR;
            reg_data        <= "ZZ" & reg_data_vec(PNR_ADDR_INT)(PACKET_NUM_WIDTH-1 downto 0) & "ZZZZZZZZ"; --& reg_data_vec(PNR_ADDR_INT)(5 downto 0);
            source_state    <= WRITE_TX_PACKET_NUMBER;  -- Must be the same as this state
            action_reg_wren <= '1';

         when CHECK_NOT_EMPTY =>
            read_nwrite     <= READ;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= POINTER_ADDR;
            reg_data        <= (others => 'Z');
            source_state    <= CHECK_NOT_EMPTY;  -- Must be the same as this state
            action_reg_wren <= '1';

         -- Get the memory offset for loading data
         when READ_POINTER_REG =>
            read_nwrite     <= READ;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= POINTER_ADDR;
            reg_data        <= (others => 'Z');
            source_state    <= READ_POINTER_REG;
            action_reg_wren <= '1';

         -- Set up the "RCV, AUTO INC, and READ" bits
         when SET_POINTER_REG =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= POINTER_ADDR;
            reg_data        <= POINTER_REG_TX(15 downto 11) & reg_data_vec(POINTER_ADDR_INT)(10 downto 0);  -- At this stage, reg_data_vec has the offset only
            source_state    <= SET_POINTER_REG;
            action_reg_wren <= '1';

            -- In preparation for LOAD_TX_DATA, clear the byte_count.
            byte_count_clr <= '1';

         when LOAD_TX_DATA =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= DATA0_ADDR;

            -- Packet Payload
            case byte_count is
               when   0 => reg_data <= BYTE_000;
               when   1 => reg_data <= BYTE_001;
               when   2 => reg_data <= BYTE_002;
               when   3 => reg_data <= BYTE_003;
               when   4 => reg_data <= BYTE_004;
               when   5 => reg_data <= BYTE_005;
               when   6 => reg_data <= BYTE_006;
               when   7 => reg_data <= BYTE_007;
               when   8 => reg_data <= BYTE_008;
               when   9 => reg_data <= BYTE_009;
               when  10 => reg_data <= BYTE_010;
               when  11 => reg_data <= BYTE_011;
               when  12 => reg_data <= BYTE_012;
               when  13 => reg_data <= BYTE_013;
               when  14 => reg_data <= BYTE_014;
               when  15 => reg_data <= BYTE_015;
               when  16 => reg_data <= BYTE_016;
               when  17 => reg_data <= BYTE_017;
               when  18 => reg_data <= BYTE_018;
               when  19 => reg_data <= BYTE_019;
               when 140 => reg_data <= BYTE_140;
               when 141 => reg_data <= BYTE_141;
               when others => reg_data <= BYTE_020_TO_139; -- Data
            end case;

            source_state    <= LOAD_TX_DATA;  -- Must be the same as this state
            action_reg_wren <= '1';

            -- Increment the byte counter.  During the first word, POINTER_ADDR gets the offset only.
            byte_count_ena <= '1';

         when WRITE_POINTER_REG =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= POINTER_ADDR;
            reg_data        <= POINTER_REG_TX(15 downto 11) & byte_count_plus_offset;  -- After the first word, POINTER_ADDR gets [byte_count + offset] = byte_count_plus_offset
            source_state    <= WRITE_POINTER_REG;  -- Must be the same as this state
            action_reg_wren <= '1';

         when ENQUEUE_PACKET =>
            read_nwrite     <= WRITE;
            bank_addr       <= BANK2_ADDR;
            reg_addr        <= MMU_COMMAND_ADDR;
            reg_data        <= ENQUEUE_PACKET_NUMBER_INTO_TX_FIFO_CMD;
            source_state    <= ENQUEUE_PACKET;  -- Must be the same as this state
            action_reg_wren <= '1';

         -- Still to do:
         -- Wait for transmission
         -- Set pointer register for read
         -- Read status word
         -- Retire packet

         when others =>

      end case;
   end process state_out;

   -----------------------------------------------------
   -- LED Toggle
   -----------------------------------------------------
   -- This trigger is way over the time needed for a ret_dat command - to see if there are bottle necks on the MCE side of things
   trigger_timer : us_timer
      port map(
         clk           => clk,
         timer_reset_i => timer_clr,
         timer_count_o => timer_count
      );

   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk, rst)
   begin
      if(rst = '1') then
         row_current_state <= IDLE;
         current_state <= PAUSE;
      elsif(clk'event and clk = '1') then
         row_current_state <= row_next_state;
         current_state <= next_state;
      end if;
   end process state_FF;

   row_state_NS: process(row_current_state, timer_count)
   begin
      -- Default assignments
      row_next_state <= row_current_state;

      case row_current_state is
         when IDLE =>
            if(timer_count >= 500000) then
               row_next_state <= TOGGLE_VAL;
            end if;

         when TOGGLE_VAL =>
            if(timer_count >= 500000) then
               row_next_state <= IDLE;
            end if;

         when others =>
            row_next_state <= IDLE;
      end case;
   end process row_state_NS;

   row_state_out: process(row_current_state, timer_count)
   begin
      -- Default assignments
      red_led_sig <= '0';
      timer_clr   <= '0';

      case row_current_state is
         when IDLE =>
            red_led_sig <= '1';
            if(timer_count >= 500000) then
               timer_clr   <= '1';
            end if;

         when TOGGLE_VAL =>
            red_led_sig <= '0';
            if(timer_count >= 500000) then
               timer_clr   <= '1';
            end if;

         when others =>
      end case;
   end process row_state_out;

   ----------------------------------------------------------------
   -- Fiber
   ----------------------------------------------------------------
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

   lvds_reply_all_a(CC)   <= lvds_reply_cc_a;
   lvds_reply_all_b(CC)   <= lvds_reply_cc_b;

   ----------------------------------------------------------------
   -- Clock Card
   ----------------------------------------------------------------
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
      manch_clk_i         => '1',  -- Manchester Clock Input
      active_clk_o        => active_clk,
      c0_o                => clk,
      c1_o                => clk_n,
      c2_o                => comm_clk,
      c3_o                => fibre_clk,
      e0_o                => fibre_tx_clkw,  -- 180 degrees out of phase with fibre_clk
      e1_o                => fibre_rx_refclk,
      e2_o                => open
   );

   ----------------------------------------------------------------
   -- Autonomous Clock Card Reset Block
   ----------------------------------------------------------------
   -- At the moment, no differentiation is made between types of resets in the frame header.
   reset_event <= brst_event or mce_bclr_event or cc_bclr_event;
   rst         <= cc_bclr or mce_bclr;

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


end top;