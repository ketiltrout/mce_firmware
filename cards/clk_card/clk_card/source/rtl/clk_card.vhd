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
-- $Id$
--
-- Project:       SCUBA-2
-- Author:        Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Clock card top-level file
--
-- Revision history:
-- $Log$
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
     -- PLL input:
     inclk      : in std_logic;
     rst        : in std_logic;
     
     -- LVDS interface:
     lvds_cmd   : in std_logic;
     lvds_sync  : in std_logic;
     lvds_spare : in std_logic;
     lvds_txa   : out std_logic;
     lvds_txb   : out std_logic;
     
     -- DV interface:
     dv_pulse_fibre  : in std_logic;
     dv_pulse_bnc    : in std_logic;
     
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
     rs232_tx   : out std_logic);
     
end clk_card;


architecture top of clk_card is

-- clocks
signal clk           : std_logic;
signal mem_clk       : std_logic;
signal comm_clk      : std_logic;
signal fibre_tx_clk  : std_logic;
signal fibre_rx_clk  : std_logic;
signal lvds_clk      : std_logic;

-- frame_timing - sync_gen interface
signal sync       : std_logic;
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
      
-- inputs from the fibre receiver 
signal fibre_clkr_i      : std_logic;
signal rx_data_i         : std_logic_vector (7 DOWNTO 0);
signal nRx_rdy_i         : std_logic;
signal rvs_i             : std_logic;
signal rso_i             : std_logic;
signal rsc_nRd_i         : std_logic;        

signal cksum_err_o       : std_logic;
    

-- interface to fibre transmitter
signal tx_data_o         : std_logic_vector (7 downto 0);      -- byte of data to be transmitted
signal tsc_nTd_o         : std_logic;                          -- hotlink tx special char/ data sel
signal nFena_o           : std_logic;                          -- hotlink tx enable

-- 25MHz clock for fibre_tx_control
signal fibre_clkw_i      : std_logic;                          -- in phase with 25MHz hotlink clock

-- lvds_tx interface
signal tx_o              : std_logic;  -- transmitter output pin
signal clk_200mhz_i      : std_logic;  -- PLL locked 25MHz input clock for the
signal sync_pulse_i      : std_logic;
signal sync_number_i     : std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);

component pll
port(
     inclk0 : in std_logic;
     e2 : out std_logic ;
     c0 : out std_logic ;
     c1 : out std_logic ;
     c2 : out std_logic ;
     e0 : out std_logic ;
     e1 : out std_logic 
     );
end component;

begin

   with addr select
      slave_data <= 
         led_data          when LED_ADDR,
         sync_gen_data     when USE_DV_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         (others => '0')   when others;
         
   with addr select
      slave_ack <= 
         led_ack          when LED_ADDR,
         sync_gen_ack    when USE_DV_ADDR,
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '0'              when others;

   pll0: pll
   port map(
            inclk0 => inclk,
            c0     => clk ,
            c1     => mem_clk ,
            c2     => comm_clk ,
            e0     => fibre_tx_clk , 
            e1     => fibre_rx_clk ,   
            e2     => lvds_clk );
            
   cmd0: dispatch
   generic map(CARD => CLOCK_CARD)
   port map(
            lvds_cmd_i   => lvds_cmd,
            lvds_reply_o => lvds_txa,
            
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
     
            wdt_rst_o => wdog);
            
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
            sync_i      => lvds_sync
            );

   issue_reply0: issue_reply
   port map(
   
   -- global signals
            rst_i          => rst,        
            clk_i          => clk,         
     
   -- inputs from the fibre receiver 
            fibre_clkr_i   => fibre_clkr_i,  
            rx_data_i      => rx_data_i,
            nRx_rdy_i      => nRx_rdy_i,
            rvs_i          => rvs_i,
            rso_i          => rso_i,
            rsc_nRd_i      => rsc_nRd_i,

            cksum_err_o    => cksum_err_o,
    
   -- interface to fibre transmitter
            tx_data_o      => tx_data_o,    -- byte of data to be transmitted
            tsc_nTd_o      => tsc_nTd_o,    -- hotlink tx special char/ data sel
            nFena_o        => nFena_o,      -- hotlink tx enable

   -- 25MHz clock for fibre_tx_control
            fibre_clkw_i   => fibre_clkw_i, -- in phase with 25MHz hotlink clock
            
   -- lvds_tx interface
            tx_o           => tx_o,         -- transmitter output pin
            clk_200mhz_i   => clk_200mhz_i, -- PLL locked 25MHz input clock for the
            sync_pulse_i   => sync_pulse_i,
            sync_number_i  => sync_number_i
   ); 

end top;