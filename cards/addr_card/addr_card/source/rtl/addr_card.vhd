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
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Address card top-level file
--
-- Revision history:
-- 
-- $Log$
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


entity addr_card is
port(-- PLL input:
     inclk      : in std_logic;
     rst        : in std_logic;
     
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
end addr_card;

architecture top of addr_card is

-- clocks
signal clk      : std_logic;
signal mem_clk  : std_logic;
signal comm_clk : std_logic;

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;

-- wishbone bus (from slaves)
signal slave_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_ack  : std_logic;
signal led_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal led_ack    : std_logic;

component pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic);
end component;

begin
   pll0: pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => mem_clk,
            c2 => comm_clk);
            
   cmd0: dispatch
   generic map(CARD => ADDRESS_CARD)
   port map(clk_i      => clk,
            mem_clk_i  => mem_clk,
            comm_clk_i => comm_clk,
            rst_i      => rst,
        
            lvds_cmd_i   => lvds_cmd,
            lvds_reply_o => lvds_txa,
     
            dat_o  => data,
            addr_o => addr,
            tga_o  => tga,
            we_o   => we,
            stb_o  => stb,
            cyc_o  => cyc,
            dat_i 	=> slave_data,
            ack_i  => slave_ack,
     
            wdt_rst_o => wdog);
            
   led0: leds
   port map(clk_i => clk,
            rst_i => rst,

            dat_i 	=> data,
            addr_i => addr,
            tga_i  => tga,
            we_i   => we,
            stb_i  => stb,
            cyc_i  => cyc,
            dat_o  => led_data,
            ack_o  => led_ack,
      
            power  => grn_led,
            status => ylw_led,
            fault  => red_led);
            
            
   slave_data <= led_data;
   slave_ack  <= led_ack;
   
end top;