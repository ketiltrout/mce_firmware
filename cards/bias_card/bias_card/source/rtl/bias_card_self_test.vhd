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
-- $Id: bias_card_self_test.vhd,v 1.1 2005/02/14 21:59:34 mandana Exp $
--
-- Project:       SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Bias Card self_test top-level file. Includes instantiation of bias card and
-- self-test blocks to create the packets and feed them in to bias card
--
-- Revision history:
-- <date $Date: 2005/02/14 21:59:34 $>    - <initials $Author: mandana $>
-- $Log: bias_card_self_test.vhd,v $
-- Revision 1.1  2005/02/14 21:59:34  mandana
-- moved from tb directory
--
-- Revision 1.5  2005/02/01 01:08:52  mandana
-- added comment for the delay value, i, to be adjusted for simulation vs. hardware test
--
-- Revision 1.4  2005/01/31 20:31:10  bench2
-- tie slot_id and ttl_nrx
-- increase the timer, so we can see LEDs flashing
--
-- Revision 1.3  2005/01/31 19:21:52  mandana
-- changed bias_card_self_test hierarchy
--
-- Revision 1.2  2005/01/27 00:21:01  mandana
-- ttl_nrx, ttl_tx, ttl_txena type change from vector to std_logic
--
-- Revision 1.1  2005/01/20 22:49:14  mandana
-- Inital Release: bias_card self-test with incoming packets pushed in from the RAM
--   
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

library work;
use work.bias_card_pack.all;
use work.all_cards_pack.all;
use work.bc_dac_ctrl_pack.all;

entity bias_card_self_test is
   port(
 
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
--      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      
      -- TTL interface:
--      ttl_nrx1   : in std_logic;
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
   --   slot_id    : in std_logic_vector(3 downto 0);
      card_id    : inout std_logic;
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic
   );
end bias_card_self_test;

architecture top of bias_card_self_test is

signal dac_ncs_temp : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_sclk_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_data_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      

-- clocks
signal clk      : std_logic;
signal clk_25   : std_logic;
signal comm_clk : std_logic;
signal clk_n    : std_logic;

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
signal id_thermo_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal id_thermo_ack     : std_logic;
signal eeprom_spi_out    : std_logic_vector( 2 downto 0);
signal eeprom_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal eeprom_ack        : std_logic;

-- frame_timing interface
signal update_bias : std_logic; 

signal debug       : std_logic_vector (31 downto 0);
-- self-test signals
signal state_shift       : std_logic;
signal lvds_lvds_tx      : std_logic;
signal rdy_lvds_tx       : std_logic;
signal busy_lvds_tx      : std_logic;
signal rdaddress_packet_ram: std_logic_vector (5 downto 0);
signal q_packet_ram      : std_logic_vector (31 downto 0);
 signal i                 : integer range 0 to 1000009;
signal bc_slot_id        : std_logic_vector(3 downto 0);
signal ttl_nrx1          : std_logic;

component packet_ram
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

begin

   bc_slot_id      <= "1110";
   ttl_nrx1        <= '0';   
   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_txena1 <= '1';
   -- The ttl_nrx1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_nrx1);
   
   mictor   <= debug;
   test (4) <= dac_ncs_temp(0);
   test (6) <= dac_data_temp(0);
   test (8) <= dac_sclk_temp(0);
      
   dac_ncs <= dac_ncs_temp;
   dac_data <= dac_data_temp;
   dac_sclk <= dac_sclk_temp;
   
   pll0: bc_pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => comm_clk,
            c2 => clk_n,
            c3 => clk_25);
            
   cmd0: dispatch
      port map(
         clk_i                      => clk,
         comm_clk_i                 => comm_clk,
         rst_i                      => rst,         
         
         lvds_cmd_i                 => lvds_lvds_tx, --lvds_cmd
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
         slot_i                     => bc_slot_id,
         dip_sw3                    => '1',
         dip_sw4                    => '1'         
      );
   eeprom_ctrl0: eeprom_ctrl
      port map(
         -- global signals      
         rst_i                      => rst,                         
         clk_25_i                   => clk_25,
         clk_50_i                   => clk,
              			
         -- Wishbone signals to/from dispatch   
         dat_i                      => data,
         addr_i                     => addr,
         tga_i                      => tga,
         we_i                       => we,
         stb_i                      => stb,
         cyc_i                      => cyc,
         dat_o                      => eeprom_data,
         ack_o                      => eeprom_ack,
            
         -- SPI interface to AT25   =>
         eeprom_spi_o               => eeprom_spi_out,
         eeprom_spi_i               => eeprom_si
      );   
      -- breakout the signals
      eeprom_so  <= eeprom_spi_out(0);
      eeprom_sck <= eeprom_spi_out(1);
      eeprom_cs  <= eeprom_spi_out(2);
      
   id_thermo0: id_thermo
      port map(
         clk_i                      => clk,
         rst_i                      => rst,  
         
         -- Wishbone signals
         dat_i 	                    => data, 
         addr_i  		    => addr,
         tga_i   		    => tga,
         we_i    		    => we,
         stb_i   		    => stb,
         cyc_i   		    => cyc,
         dat_o   		    => id_thermo_data,
         ack_o   		    => id_thermo_ack,
            
         -- silicon id/temperature chip signals
         data_io                    => card_id
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
         clk_n_i                    => clk_n,
         rst_i                      => rst,
         sync_i                     => lvds_sync
      );
   
   with addr select
      slave_data <= 
         led_data          when LED_ADDR,
         bc_dac_data       when FLUX_FB_ADDR | BIAS_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         id_thermo_data    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         eeprom_data       when EEPROM_ADDR  | EEPROM_SRT_ADDR,
         (others => '0')   when others;

   with addr select
      slave_ack <= 
         led_ack          when LED_ADDR,
         bc_dac_ack       when FLUX_FB_ADDR | BIAS_ADDR,
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         id_thermo_ack    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         eeprom_ack       when EEPROM_ADDR  | EEPROM_SRT_ADDR,
         '0'              when others;
         
   with addr select
      slave_err <= 
         '0'              when LED_ADDR | FLUX_FB_ADDR | BIAS_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | 
                               SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR|
                               CARD_ID_ADDR | CARD_TEMP_ADDR | EEPROM_ADDR  | EEPROM_SRT_ADDR, 
         '1'              when others;        
-------------------------------------------------------------------------------

-- blocks to enable HW test without the clk card

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- packet ram
-------------------------------------------------------------------------------
  i_packet_ram: packet_ram
    port map (
        data      => (others => '0'),
        wren      => '0',
        address => rdaddress_packet_ram,
        clock     => clk,
        q         => q_packet_ram);
-------------------------------------------------------------------------------
-- lvds_tx
-------------------------------------------------------------------------------
  i_lvds_tx: lvds_tx
    port map (
        clk_i  => clk,
        rst_i  => rst,
        dat_i  => q_packet_ram,
        rdy_i  => rdy_lvds_tx,
        busy_o => busy_lvds_tx,
        lvds_o => lvds_lvds_tx);
 
  rdy_lvds_tx <= state_shift;
-------------------------------------------------------------------------------
-- our fsm
-------------------------------------------------------------------------------
  i_fsm: process (clk, rst)
 
  --  variable i : integer range 0 to 1000009;
  begin  -- process i_fsm
    if rst = '1' then                   -- asynchronous reset
      state_shift <= '0';
      i           <=  0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      state_shift <= '0';
      i <= i + 1;
      -- set the i value to 1000000 for synthesis, so led flashing is visible on hardware
      -- set the i value to 400 for simulation      
      if i = 400 then
        state_shift <= '1';
        i <= 0;
      end if;
    end if;
  end process i_fsm;
 
  i_count_up: process (clk, rst)

  begin  -- process i_count_up
    if rst = '1' then                   -- asynchronous reset
      rdaddress_packet_ram <= (others => '0');
     
    elsif clk'event and clk = '1' then  -- rising clock edge
      if state_shift='1' then
        if rdaddress_packet_ram <x"31" then
          rdaddress_packet_ram <= rdaddress_packet_ram + 1;
        else
          rdaddress_packet_ram <= (others => '0');
        end if;
      end if;
    end if;
  end process i_count_up;

-------------------------------------------------------------------------------
-- End of added blocks for HW test
-------------------------            
   
end top;