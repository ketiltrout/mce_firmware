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
-- $Id: bias_card_self_test.vhd,v 1.1 2005/01/20 22:49:14 mandana Exp $
--
-- Project:       SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Address Card self_test top-level file. Includes instantiation of bias card and
-- self-test blocks to create the packets and feed them in to bias card
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$
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
use work.addr_card_pack.all;
use work.dispatch_pack.all;
use work.leds_pack.all;
use work.frame_timing_pack.all;
use work.ac_dac_ctrl_pack.all;
use work.async_pack.all;

entity addr_card_self_test is
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
end addr_card_self_test;

architecture top of addr_card_self_test is

-- clocks
signal clk      : std_logic;
signal mem_clk : std_logic;
signal comm_clk : std_logic;


-- self-test signals
signal state_shift       : std_logic;
signal lvds_lvds_tx      : std_logic;
signal rdy_lvds_tx       : std_logic;
signal busy_lvds_tx      : std_logic;
signal rdaddress_packet_ram: std_logic_vector (5 downto 0);
signal q_packet_ram      : std_logic_vector (31 downto 0);
signal rst               : std_logic;
signal i                 : integer range 0 to 509;

component ac_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic);
end component;

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
   
   pll1: ac_pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => mem_clk,
            c2 => comm_clk);

   i_addr_card: addr_card
    port map(
         -- PLL input:
         inclk            => inclk,
         rst_n            => rst_n,
         
         -- LVDS interface:
         lvds_cmd         => lvds_lvds_tx, --lvds_cmd,  
         lvds_sync        => lvds_sync, 
         lvds_spare       => lvds_spare,
         lvds_txa         => lvds_txa, 
         lvds_txb         => lvds_txb, 
         
         -- TTL interface:
         ttl_nrx1          => ttl_nrx1,  
         ttl_tx1           => ttl_tx1,   
         ttl_txena1        => ttl_txena1,
         
         ttl_nrx2          => ttl_nrx2,  
         ttl_tx2           => ttl_tx2,   
         ttl_txena2        => ttl_txena2,

         ttl_nrx3          => ttl_nrx3,  
         ttl_tx3           => ttl_tx3,   
         ttl_txena3        => ttl_txena3,

         -- eeprom interface:
         eeprom_si        => eeprom_si, 
         eeprom_so        => eeprom_so, 
         eeprom_sck       => eeprom_sck,
         eeprom_cs        => eeprom_cs, 
         
         -- dac interface:
         dac_data0        => dac_data0,  
         dac_data1        => dac_data1,  
         dac_data2        => dac_data2,  
         dac_data3        => dac_data3,  
         dac_data4        => dac_data4,  
         dac_data5        => dac_data5,  
         dac_data6        => dac_data6,  
         dac_data7        => dac_data7,  
         dac_data8        => dac_data8,  
         dac_data9        => dac_data9,  
         dac_data10       => dac_data10, 
         dac_clk          => dac_clk,    
         
         -- miscellaneous ports:
         red_led          => red_led, 
         ylw_led          => ylw_led, 
         grn_led          => grn_led, 
         dip_sw3          => dip_sw3, 
         dip_sw4          => dip_sw4, 
         wdog             => wdog,    
         slot_id          => slot_id, 
         
         -- debug ports:
         test             => test,       
         mictor           => mictor,     
         mictorclk        => mictorclk,  
         rs232_rx         => rs232_rx,
         rs232_tx         => rs232_tx
  );     
    rst <= not rst_n;

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
 
--    variable i : integer range 0 to 1000009;
  begin  -- process i_fsm
    if rst = '1' then                   -- asynchronous reset
      state_shift <= '0';
      i           <=  0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      state_shift <= '0';
      i <= i + 1;
      if i = 500 then
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
        if rdaddress_packet_ram <x"2e" then
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