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
--
-- readout_card_pack.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- The package file for the all_cards vhdl components.
--
--
-- Revision history:
-- <date $Date: 2009/12/09 00:31:54 $>    - <initials $Author: mandana $>
-- $Log: all_cards_pack.vhd,v $
-- Revision 1.11  2009/12/09 00:31:54  mandana
-- added spi_dac_ctrl for controlling SPI DACs
--
-- Revision 1.10  2009/09/14 20:03:08  bburger
-- BB: added the row_count_o interface for the Address Card row-specific BIAS_START command
--
-- Revision 1.9  2009/08/21 21:07:24  bburger
-- BB: added FPGA_DEVICE_FAMILY generic to interfaces for synthesis for Stratix I or III
--
-- Revision 1.8  2009/05/27 22:30:45  bburger
-- BB: Added data_size_o interface to wishbone entity for rectangle mode data acquisition
--
-- Revision 1.7  2009/01/16 01:31:20  bburger
-- BB: renamed some output signals on all_cards to conform to the wishbone standard.
--
-- Revision 1.6  2008/12/22 20:26:29  bburger
-- BB:  Added a second LVDS reply channel to dispatch
--
-- Revision 1.5  2008/01/26 01:10:10  mandana
-- added all_cards slave to integrate fw_rev, slot_id, card_type, scratch
--
-- Revision 1.4  2007/07/25 19:27:34  bburger
-- BB:  Cosmetic changes
--
-- Revision 1.3  2007/03/06 00:49:03  bburger
-- Bryce:  added the smbalert_i signal to the fpga_thermo interface
--
-- Revision 1.2  2007/02/19 23:30:18  mandana
-- modified id_thermo interface
--
-- Revision 1.1  2006/05/05 19:17:43  mandana
-- initial release
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
-- System Library
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.frame_timing_pack.all;

package all_cards_pack is
   constant PCB_REV_BITS : integer := 4;
   constant SLOT_ID_BITS : integer := 4;
   constant SPI_DATA_WIDTH:  integer := 3;
   -----------------------------------------------------------------------------
   -- all_cards component
   -----------------------------------------------------------------------------
   component all_cards
      generic( 
         REVISION: std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"01010000";
         CARD_TYPE: std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := b"111"
      );
      port(
         clk_i   : in std_logic;
         rst_i   : in std_logic;

         -- Wishbone signals
         dat_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
         addr_i  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
         tga_i   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
         we_i    : in std_logic;
         stb_i   : in std_logic;
         cyc_i   : in std_logic;
         slot_id_i         : in std_logic_vector(SLOT_ID_BITS-1 downto 0);
         pcb_rev_i : in std_logic_vector(PCB_REV_BITS-1 downto 0);
         err_o   : out std_logic;
         dat_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         ack_o   : out std_logic
      );
   end component;

   -----------------------------------------------------------------------------
   -- LED Component
   -----------------------------------------------------------------------------
   component leds
      port(
         clk_i   : in std_logic;
         rst_i   : in std_logic;

         -- Wishbone signals
         dat_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
         addr_i  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
         tga_i   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
         we_i    : in std_logic;
         stb_i   : in std_logic;
         cyc_i   : in std_logic;
         dat_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         ack_o   : out std_logic;

         -- LED outputs
         power   : out std_logic;
         status  : out std_logic;
         fault   : out std_logic
      );
   end component;

   -----------------------------------------------------------------------------
   -- Dispatch component
   -----------------------------------------------------------------------------
   component dispatch
      generic (
         FPGA_DEVICE_FAMILY : string := "Stratix");
      port(
         clk_i      : in std_logic;
         comm_clk_i : in std_logic;
         rst_i      : in std_logic;

         -- bus backplane interface (LVDS)
         lvds_cmd_i   : in std_logic;
         lvds_replya_o : out std_logic;
         lvds_replyb_o : out std_logic;

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
         data_size_o : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

         dip_sw3 : in std_logic;
         dip_sw4 : in std_logic
      );
   end component;

   -----------------------------------------------------------------------------
   -- frame_timing component
   -----------------------------------------------------------------------------
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
         row_len_o                  : out integer;
         num_rows_o                 : out integer;
         num_rows_reported_o     : out integer;
         num_cols_reported_o     : out integer;

         -- Address Card interface
         row_count_o                : out std_logic_vector(ROW_COUNT_WIDTH-1 downto 0);
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

   -----------------------------------------------------------------------------
   -- FPGA_thermo component
   -----------------------------------------------------------------------------
   component fpga_thermo
      port(
         clk_i   : in std_logic;
         rst_i   : in std_logic;

         -- wishbone signals
         dat_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         addr_i  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
         tga_i   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
         we_i    : in std_logic;
         stb_i   : in std_logic;
         cyc_i   : in std_logic;
         err_o   : out std_logic;
         dat_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         ack_o   : out std_logic;

         -- SMBus temperature sensor signals
         smbclk_o : out std_logic;
         smbalert_i : in std_logic;
         smbdat_io : inout std_logic
      );
   end component;

   -----------------------------------------------------------------------------
   -- Thermometer Component
   -----------------------------------------------------------------------------
   component id_thermo
      port(
         clk_i   : in std_logic;
         rst_i   : in std_logic;

         -- Wishbone signals
         dat_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         addr_i  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
         tga_i   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
         we_i    : in std_logic;
         stb_i   : in std_logic;
         cyc_i   : in std_logic;
         err_o   : out std_logic;
         dat_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
         ack_o   : out std_logic;

         data_io : inout std_logic
      );
   end component;
   
   -----------------------------------------------------------------------------
   -- 3-wire SPI DAC Control block
   -----------------------------------------------------------------------------
   
   component spi_dac_ctrl 
      generic (
         DAC_DATA_WIDTH : integer range 1 to 32 := 16;
         CLK_RATIO : integer range 1 to 8 := 2                                                  -- divided ratio of fast (MAIN) clock to slow (SPI) clock
      );
      port( 
         -- global signals
         rst_i                     : in     std_logic;                                     -- global reset
         clk_25_i                  : in     std_logic;                                     -- global clock (25 MHz)
         clk_50_i                  : in     std_logic;                                     -- global clock (50 MHz)
              
         -- control signals from frame timing block
         restart_frame_aligned_i   : in     std_logic;                                     -- start of frame signal (50 MHz domain)
         
         -- control signal indicates dat_i is updated
         dat_rdy_i                 : in     std_logic;
         
         -- parallel data to be serialized
         dat_i                     : in     std_logic_vector(DAC_DATA_WIDTH-1 downto 0);    -- parallel data input value from wishbone 
         
         -- SPI interface to MAX 5443 DAC
         dac_spi_o                 : out    std_logic_vector(SPI_DATA_WIDTH-1 downto 0)    -- serial (SPI) data, clock and chip select          
   );   
   end component;
   

end all_cards_pack;

