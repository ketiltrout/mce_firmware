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
-- $Id: clk_card.vhd,v 1.6 2004/11/29 23:35:32 bench2 Exp $
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
-- Revision 1.6  2004/11/29 23:35:32  bench2
-- Greg: Added err_i and extended FIBRE_CHECKSUM_ERR to 8-bits for reply_argument in reply_translator.vhd
--
-- Revision 1.5  2004/11/29 10:37:07  dca
-- Changed PLL instantiation.
--
-- Revision 1.4  2004/11/25 15:18:18  dca
-- moved a signal
--
-- Revision 1.3  2004/11/25 15:15:51  dca
-- various signals removed from architecture
--
-- Revision 1.2  2004/11/25 01:09:12  bench2
-- Greg: Changed issue_reply block instantiation and corresponding signals in the tcl file
--
-- Revision 1.1  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.dispatch_pack.all;
use work.leds_pack.all;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;


entity clk_card is
   port(
      -- simulation signals
      clk          : in std_logic;
      mem_clk      : in std_logic;
      comm_clk     : in std_logic;      
      fibre_clk    : in std_logic;
      fibre_tx_clk : in std_logic;
      fibre_rx_clk : in std_logic;
      lvds_clk_i   : in std_logic; 
      
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
      lvds_cmd   : out std_logic;
      lvds_sync  : out std_logic;
      lvds_spare : out std_logic;
      lvds_clk   : out std_logic;
      lvds_reply_ac_a  : in std_logic;  
      lvds_reply_ac_b  : in std_logic;
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
      dv_pulse_fibre  : in std_logic;
      dv_pulse_bnc    : in std_logic;
      
      -- TTL interface:
--     ttl_nrx    : in std_logic_vector(3 downto 1);
--     ttl_tx     : out std_logic_vector(3 downto 1);
--     ttl_txena  : out std_logic_vector(3 downto 1);
     
      -- eeprom interface:
      eeprom_si  : in std_logic;
      eeprom_so  : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs  : out std_logic;
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      mictor_o    : out std_logic_vector(15 downto 1);
      mictorclk_o : out std_logic;
      mictor_e    : out std_logic_vector(15 downto 1);
      mictorclk_e : out std_logic;
      rs232_rx    : in std_logic;
      rs232_tx    : out std_logic;
      
      -- interface to HOTLINK fibre receiver      
      fibre_rx_data      : in std_logic_vector (7 downto 0);  
      fibre_rx_rdy       : in std_logic;                      
      fibre_rx_rvs       : in std_logic;                      
      fibre_rx_status    : in std_logic;                      
      fibre_rx_sc_nd     : in std_logic;                      
      fibre_rx_ckr       : in std_logic;                      
      
      -- interface to hotlink fibre transmitter      
      fibre_tx_data      : out std_logic_vector (7 downto 0);
      fibre_tx_ena       : out std_logic;  
      fibre_tx_sc_nd     : out std_logic
   );     
end clk_card;

architecture top of clk_card is

-- reset
signal rst           : std_logic;

-- clocks
--signal clk           : std_logic;
--signal mem_clk       : std_logic;
--signal comm_clk      : std_logic;
--signal fibre_clk     : std_logic;
--signal fibre_tx_clk  : std_logic;
--signal fibre_rx_clk  : std_logic;

-- sync_gen interface
signal sync_num   : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;

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
      
-- lvds_tx interface
signal sync       : std_logic;
signal cmd        : std_logic;

-- lvds_rx interface
signal lvds_reply_cc_a     : std_logic;

-- For testing
signal debug             : std_logic_vector(31 downto 0);

component pll
   port(
      inclk0 : in std_logic;
      e2     : out std_logic ;
      c0     : out std_logic ;
      c1     : out std_logic ;
      c2     : out std_logic ;
      c3     : out std_logic ;
      e0     : out std_logic ;
      e1     : out std_logic 
   );
end component;


begin

   rst <= NOT rst_n;

   with addr select
      slave_data <= 
         led_data          when LED_ADDR,
         sync_gen_data     when USE_DV_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         (others => '0')   when others;
         
   with addr select
      slave_ack <= 
         led_ack          when LED_ADDR,
         sync_gen_ack     when USE_DV_ADDR,
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '0'              when others;
         
   with addr select
      slave_err <= 
         '0'              when LED_ADDR | USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '1'              when others;

   lvds_clk <= lvds_clk_i;
--   pll0: pll
--      port map(
--         inclk0 => inclk,
--         c0     => clk,
--         c1     => mem_clk,
--         c2     => comm_clk,
--         c3     => fibre_clk,
--         e0     => fibre_tx_clk, 
--         e1     => fibre_rx_clk,   
--         e2     => lvds_clk 
--      );
            
   lvds_cmd <= cmd;
   cmd0: dispatch
      generic map(
         CARD => CLOCK_CARD
      )
      port map(
         lvds_cmd_i   => cmd,
         lvds_reply_o => lvds_reply_cc_a,
         
         --  Global signals
         clk_i      => clk,
         mem_clk_i  => mem_clk,
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
     
         wdt_rst_o => wdog
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
   
   lvds_sync <= sync;
   sync_gen0: sync_gen
      port map( 
         -- Inputs/Outputs
         dv_i       => dv_pulse_fibre,
         sync_o     => sync,
         sync_num_o => sync_num,
      
         -- Wishbone interface
         dat_i       => data,         
         addr_i      => addr,           
         tga_i       => tga,
         we_i        => we,          
         stb_i       => stb,            
         cyc_i       => cyc,       
         dat_o       => sync_gen_data,          
         ack_o       => sync_gen_ack,
      
         --  Global signals
         clk_i       => clk,
         mem_clk_i   => mem_clk,
         rst_i       => rst
      );

   frame_timing0: frame_timing   
      port map(   
         -- Readout Card interface
         dac_dat_en_o               => open,
         adc_coadd_en_o             => open,
         restart_frame_1row_prev_o  => open,
         restart_frame_aligned_o    => open, 
         restart_frame_1row_post_o  => open,
         initialize_window_o        => open,
          
         -- Address Card interface
         row_switch_o               => open,
         row_en_o                   => open,
             
         -- Bias Card interface       
         update_bias_o              => open,
      
         -- Wishbone interface
         dat_i    => data,
         addr_i   => addr,                   
         tga_i    => tga,                    
         we_i     => we,
         stb_i    => stb,                      
         cyc_i    => cyc,                   
         dat_o    => frame_timing_data,                     
         ack_o    => frame_timing_ack,
      
         -- Global signals
         clk_i       => clk,
         mem_clk_i   => mem_clk,               
         rst_i       => rst,
         sync_i      => sync
      );

   issue_reply0: issue_reply
      port map(   
         -- For testing
         debug_o    => debug,
   
         -- global signals
         rst_i             => rst,
         clk_i             => clk,
         comm_clk_i        => comm_clk,
         mem_clk_i         => mem_clk,
         
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
         fibre_clkr_i      => fibre_rx_ckr,  
         rx_data_i         => fibre_rx_data,
         nRx_rdy_i         => fibre_rx_rdy,
         rvs_i             => fibre_rx_rvs,
         rso_i             => fibre_rx_status,
         rsc_nRd_i         => fibre_rx_sc_nd,
         cksum_err_o       => open,
    
         -- fibre transmitter interface
         tx_data_o         => fibre_tx_data,     -- byte of data to be transmitted
         tsc_nTd_o         => fibre_tx_sc_nd,    -- hotlink tx special char/ data sel
         nFena_o           => fibre_tx_ena,      -- hotlink tx enable
   
         -- 25MHz clock for fibre_tx_control
         fibre_clkw_i      => fibre_clk,
        
         -- lvds_tx interface
         lvds_cmd_o        => cmd,

         sync_pulse_i      => sync,
         sync_number_i     => sync_num
      );
  
end top;