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
-- addr_card.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Address card top-level file
--
-- Revision history:
-- 
-- $Log: addr_card.vhd,v $
-- Revision 1.8  2005/01/18 22:20:47  bburger
-- Bryce:  Added a BClr signal across the bus backplane to all the card top levels.
--
-- Revision 1.7  2005/01/13 03:14:51  bburger
-- Bryce:
-- addr_card and clk_card:  added slot_id functionality, removed mem_clock
-- sync_gen and frame_timing:  added custom counters and registers
--
-- Revision 1.6  2004/12/08 22:15:12  bburger
-- Bryce:  changed the usage of PLLs in the top levels of clk and addr cards
--
-- Revision 1.5  2004/12/06 07:22:34  bburger
-- Bryce:
-- Created pack files for the card top-levels.
-- Added some simulation signals to the top-levels (i.e. clocks)
--
-- Revision 1.4  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.3  2004/11/20 01:20:44  bburger
-- Bryce :  fixed a bug in the ac_dac_ctrl_core block that did not load the off value of the row at the end of a frame.
--
-- Revision 1.2  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.1  2004/10/13 20:05:01  erniel
-- initial version
-- led module only
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.dispatch_pack.all;
use work.leds_pack.all;
use work.frame_timing_pack.all;
use work.ac_dac_ctrl_pack.all;

entity addr_card is
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
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(32 downto 1);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic    
   );
end addr_card;

architecture top of addr_card is

-- clocks
signal clk      : std_logic;
signal mem_clk  : std_logic;
signal comm_clk : std_logic;

signal rst      : std_logic;

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;

-- wishbone bus (from slaves)
signal slave_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_ack         : std_logic;
signal led_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal led_ack           : std_logic;
signal ac_dac_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal ac_dac_ack        : std_logic;
signal frame_timing_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal frame_timing_ack  : std_logic;
signal slave_err         : std_logic;

-- frame_timing interface
signal restart_frame_aligned : std_logic; 
signal row_switch            : std_logic;
signal row_en                : std_logic;

-- DAC hardware interface:
signal dac_data : w14_array11;   

component ac_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic);
end component;

begin
   
   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_txena1 <= '1';
   rst <= (not rst_n) or (not ttl_nrx1);
   
   pll0: ac_pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => mem_clk,
            c2 => comm_clk);
            
   cmd0: dispatch
      port map(
         clk_i                      => clk,
         comm_clk_i                 => comm_clk,
         rst_i                      => rst,
        
         lvds_cmd_i                 => lvds_cmd,
         lvds_reply_o               => lvds_txa,
     
         dat_o                      => data,
         addr_o                     => addr,
         tga_o                      => tga,
         we_o                       => we,
         stb_o                      => stb,
         cyc_o                      => cyc,
         dat_i                      => slave_data,
         ack_i                      => slave_ack,
         err_i                      => slave_err, 
     
         wdt_rst_o                  => wdog,
         slot_i                     => slot_id
      );
            
   leds_slave: leds
      port map(
         clk_i                      => clk,
         rst_i                      => rst,

         dat_i                      => data,
         addr_i                     => addr,
         tga_i                      => tga,
         we_i                       => we,
         stb_i                      => stb,
         cyc_i                      => cyc,
         dat_o                      => led_data,
         ack_o                      => led_ack,
         
         power                      => grn_led,
         status                     => ylw_led,
         fault                      => red_led
      );
            
   ac_dac_ctrl_slave: ac_dac_ctrl
      port map(
         dac_data_o                 => dac_data,
         dac_clks_o                 => dac_clk,
      
         dat_i                      => data,
         addr_i                     => addr,
         tga_i                      => tga,
         we_i                       => we,
         stb_i                      => stb,
         cyc_i                      => cyc,
         dat_o                      => ac_dac_data,
         ack_o                      => ac_dac_ack,

         row_switch_i               => row_switch,
         restart_frame_aligned_i    => restart_frame_aligned,
         row_en_i                   => row_en,
                                    
         clk_i                      => clk,
         mem_clk_i                  => mem_clk,
         rst_i                      => rst
      );                         
                                 
   frame_timing_slave: frame_timing
      port map(
         dac_dat_en_o               => open,
         adc_coadd_en_o             => open,
         restart_frame_1row_prev_o  => open,
         restart_frame_aligned_o    => restart_frame_aligned,
         restart_frame_1row_post_o  => open,
         initialize_window_o        => open,
         
         row_switch_o               => row_switch,
         row_en_o                   => row_en,
            
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
         mem_clk_i                  => mem_clk,
         rst_i                      => rst,
         sync_i                     => lvds_sync
      );
   
   dac_data0  <= dac_data(0);
   dac_data1  <= dac_data(1);
   dac_data2  <= dac_data(2);
   dac_data3  <= dac_data(3);
   dac_data4  <= dac_data(4);
   dac_data5  <= dac_data(5);
   dac_data6  <= dac_data(6);
   dac_data7  <= dac_data(7);
   dac_data8  <= dac_data(8);
   dac_data9  <= dac_data(9);
   dac_data10 <= dac_data(10);
   
   with addr select
      slave_data <= 
         led_data          when LED_ADDR,
         ac_dac_data       when ON_BIAS_ADDR | OFF_BIAS_ADDR | ENBL_MUX_ADDR   | ROW_ORDER_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         (others => '0')   when others;

   with addr select
      slave_ack <= 
         led_ack          when LED_ADDR,
         ac_dac_ack       when ON_BIAS_ADDR | OFF_BIAS_ADDR | ENBL_MUX_ADDR   | ROW_ORDER_ADDR,
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '0'              when others;
         
   with addr select
      slave_err <= 
         '0'              when LED_ADDR | ON_BIAS_ADDR | OFF_BIAS_ADDR | ENBL_MUX_ADDR | ROW_ORDER_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '1'              when others;
         
   
end top;