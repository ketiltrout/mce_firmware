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
-- $Id: bias_card.vhd,v 1.4 2005/01/04 19:19:47 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Bias Card top-level file
--
-- Revision history:
-- 
-- $Log: bias_card.vhd,v $
-- Revision 1.4  2005/01/04 19:19:47  bburger
-- Mandana: changed mictor assignment to 0 to 31 and swapped odd and even pods
--
-- Revision 1.3  2004/12/21 22:06:51  bburger
-- Bryce:  update
--
-- Revision 1.2  2004/12/16 18:09:35  bench2
-- Mandana: fixed the clocking, added bc_pll
--
-- Revision 1.1  2004/12/06 07:22:34  bburger
-- Bryce:
-- Created pack files for the card top-levels.
-- Added some simulation signals to the top-levels (i.e. clocks)
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
use work.bc_dac_ctrl_pack.all;

entity bias_card is
   generic(
      CARD : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := BIAS_CARD_1
   );
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
      ttl_nrx    : in std_logic_vector(3 downto 1);
      ttl_tx     : out std_logic_vector(3 downto 1);
      ttl_txena  : out std_logic_vector(3 downto 1);

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
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic
   );
end bias_card;

architecture top of bias_card is

signal dac_ncs_temp : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_sclk_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_data_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      

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
signal bc_dac_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal bc_dac_ack        : std_logic;
signal frame_timing_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal frame_timing_ack  : std_logic;
signal slave_err         : std_logic;

-- frame_timing interface
signal update_bias : std_logic; 

signal debug       : std_logic_vector (31 downto 0);

component bc_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic);
end component;

begin
   
   rst <= not rst_n;
   mictor <= debug;
   test (4) <= dac_ncs_temp(0);
   test (6) <= dac_data_temp(0);
   test (8) <= dac_sclk_temp(0);
      
   dac_ncs <= dac_ncs_temp;
   dac_data <= dac_data_temp;
   dac_sclk <= dac_sclk_temp;
   
   pll0: bc_pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => mem_clk,
            c2 => comm_clk);
            
   cmd0: dispatch
      generic map(
         CARD => CARD
         )
      port map(
         clk_i                      => clk,
         mem_clk_i                  => mem_clk,
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
     
         wdt_rst_o                  => wdog
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
            
   bc_dac_ctrl_slave: bc_dac_ctrl
      port map(
         -- DAC hardware interface:
         -- There are 32 DAC channels, thus 32 serial data/cs/clk lines.
         flux_fb_data_o             => dac_data_temp,      
         flux_fb_ncs_o              => dac_ncs_temp,     
         flux_fb_clk_o              => dac_sclk_temp,     
                                       
         bias_data_o                => lvds_dac_data,
         bias_ncs_o                 => lvds_dac_ncs,
         bias_clk_o                 => lvds_dac_sclk,
         
         dac_nclr_o                 => dac_nclr,
         
         -- wishbone interface:
         dat_i                      => data,
         addr_i                     => addr,
         tga_i                      => tga, 
         we_i                       => we,  
         stb_i                      => stb, 
         cyc_i                      => cyc, 
         dat_o                      => bc_dac_data,
         ack_o                      => bc_dac_ack,
         
         -- frame_timing signals
         update_bias_i              => update_bias,
         
         -- Global Signals      
         clk_i                      => clk,
         mem_clk_i                  => mem_clk,
         rst_i                      => rst,
         debug                      => debug
      );                         
                                 
   frame_timing_slave: frame_timing
      port map(
         dac_dat_en_o               => open,
         adc_coadd_en_o             => open,
         restart_frame_1row_prev_o  => open,
         restart_frame_aligned_o    => open,
         restart_frame_1row_post_o  => open,
         initialize_window_o        => open,
         
         row_switch_o               => open,
         row_en_o                   => open,
            
         update_bias_o              => update_bias,
         
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
   
   with addr select
      slave_data <= 
         led_data          when LED_ADDR,
         bc_dac_data       when FLUX_FB_ADDR | BIAS_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         (others => '0')   when others;

   with addr select
      slave_ack <= 
         led_ack          when LED_ADDR,
         bc_dac_ack       when FLUX_FB_ADDR | BIAS_ADDR,
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '0'              when others;
         
   with addr select
      slave_err <= 
         '0'              when LED_ADDR | FLUX_FB_ADDR | BIAS_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '1'              when others;        
   
end top;