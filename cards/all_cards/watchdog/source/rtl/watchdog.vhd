-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- <Title>
--
-- <revision control keyword substitutions e.g. $Id: watchdog.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC
--
-- Description:
-- This file implements the Array ID functionality
--
-- Revision history:
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.watchdog_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
-- contains slave_ctrl, us_timer and counter
use components.component_pack.all;

entity watchdog is
   generic (
      SLAVE_SEL : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := WATCHDOG_ADDR;
      ADDR_WIDTH : integer := WB_ADDR_WIDTH;
      DATA_WIDTH : integer := WB_DATA_WIDTH;
      TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
   );
   port (   
      -- Wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;		
      dat_i 	 : in std_logic_vector (DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
      addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
      rty_o   : out std_logic;
      ack_o   : out std_logic;
      
      -- WATCHDOG outputs
      you_kick_my_dog : out std_logic
--      wdt_reached_lim : out integer;
--      wshbn_notreached_lim : out integer;
--      wshbn_mach_state : out std_logic_vector(1 downto 0)
   );
end watchdog;

architecture rtl of watchdog is

-- internal signals
signal wshbn_timer_rst_state : std_logic_vector(1 downto 0);
signal wshbn_timer_rst_next_state : std_logic_vector(1 downto 0);
signal wshbn_timer_count_sig : integer;
signal wshbn_timer_has_not_reached_limit : std_logic;
signal wshbn_timer_state_mach_sig : std_logic;
signal wshbn_timer_rst_sig : std_logic;

signal wdt_timer_count_sig : integer;
signal wdt_timer_has_reached_limit : std_logic;
signal wdt_timer_rst_sig : std_logic;

-- need to initialize dat_o_watchdog to zero for all time.  No reading done from the WDT
signal dat_o_watchdog : std_logic_vector(DATA_WIDTH-1 downto 0);

signal dat_i_watchdog : std_logic_vector(DATA_WIDTH-1 downto 0);
signal slave_wr_ready_sig : std_logic;
signal slave_rd_data_valid_sig : std_logic;

-- what is this signal for?
signal slave_wr_data_valid_sig : std_logic;

signal no_connect : std_logic;

-- states for the Wishbone FSM
constant IDLE      : std_logic_vector(1 downto 0) := "00";
constant RESET     : std_logic_vector(1 downto 0) := "01";
constant NO_RESET  : std_logic_vector(1 downto 0) := "10";

constant WDT_TIMER_LIMIT : integer := 180000; -- u-seconds, the wdt timeout is about 200000 us.

-- This is the time after which the watchdog_block will not allow the WDT_Timer to kick the WDT
-- In other words, the watchdog_block must receive a '1' dat_i_watchdog(0) line every 5 s.
constant WSHBN_TIMER_LIMIT : integer := 5000000; -- u-seconds

begin

------------------------------------------------------------------------
--
--  Wishbone Reset State Machine
--
------------------------------------------------------------------------

   process (wshbn_timer_rst_state, slave_wr_data_valid_sig, dat_i_watchdog)
   begin
      case wshbn_timer_rst_state is

      when IDLE =>
         wshbn_timer_state_mach_sig <= '0';
         if slave_wr_data_valid_sig = '1' then
            if dat_i_watchdog = WATCHDOG_KICK then
               wshbn_timer_rst_next_state <= RESET;
            end if;
         end if;
      
      when RESET =>
         wshbn_timer_state_mach_sig <= '1';
         wshbn_timer_rst_next_state <= NO_RESET;
      
      when NO_RESET =>
         wshbn_timer_state_mach_sig <= '0';
         if slave_wr_data_valid_sig = '1' then
            if dat_i_watchdog = WATCHDOG_KICK then
               wshbn_timer_rst_next_state <= NO_RESET;
            else
               wshbn_timer_rst_next_state <= IDLE;
            end if;
         else
            wshbn_timer_rst_next_state <= IDLE;
         end if;
        
      when others => 
         wshbn_timer_rst_next_state <= IDLE;
      end case;
   end process;

------------------------------------------------------------------------
--
-- State Sequencer
--
------------------------------------------------------------------------

   process (clk_i, rst_i)
   begin
      if rst_i = '1' then
         wshbn_timer_rst_state <= IDLE;
      elsif (clk_i'event and clk_i = '1') then
         wshbn_timer_rst_state <= wshbn_timer_rst_next_state;
      end if;
   end process;

------------------------------------------------------------------------
--
-- Watchdog Reset
--
------------------------------------------------------------------------
     
   wshbn_timer_rst_sig <= rst_i or wshbn_timer_state_mach_sig;
   wdt_timer_rst_sig <= rst_i or wdt_timer_has_reached_limit;
   wdt_timer_has_reached_limit <= '1' when wdt_timer_count_sig = WDT_TIMER_LIMIT else '0';
   wshbn_timer_has_not_reached_limit <= '1' when wshbn_timer_count_sig < WSHBN_TIMER_LIMIT else '0';
   you_kick_my_dog <= wshbn_timer_has_not_reached_limit and wdt_timer_has_reached_limit;
   
--   wdt_reached_lim <= wdt_timer_count_sig;
--   wshbn_notreached_lim <= wshbn_timer_count_sig;
--   wshbn_mach_state <= wshbn_timer_rst_state;
   
   -- Watchdog is always ready to be written to
   slave_wr_ready_sig <= '1';
   -- Watchdog doesn't have a data register which can be read 
   slave_rd_data_valid_sig <= '0'; 

   wshbn_timer : us_timer
   port map (
      clk => clk_i,
      timer_reset_i => wshbn_timer_rst_sig,
      timer_count_o => wshbn_timer_count_sig  
   );
   
   wdt_timer : us_timer
   port map (
      clk => clk_i,
      timer_reset_i => wdt_timer_rst_sig,
      timer_count_o => wdt_timer_count_sig  
   );
   
------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 

   watchdog_slave_ctrl : slave_ctrl
   generic map (
      SLAVE_SEL  => WATCHDOG_ADDR,
      ADDR_WIDTH => WB_ADDR_WIDTH,
      DATA_WIDTH => WB_DATA_WIDTH,
      TAG_ADDR_WIDTH => TAG_ADDR_WIDTH
   )
   port map (
      slave_wr_ready        => slave_wr_ready_sig,
      slave_rd_data_valid   => slave_rd_data_valid_sig,
      slave_retry           => no_connect,
      master_wr_data_valid  => slave_wr_data_valid_sig,
      slave_ctrl_dat_i      => dat_o_watchdog,
      slave_ctrl_dat_o      => dat_i_watchdog,
      clk_i                 => clk_i,
      rst_i                 => rst_i,
      dat_i                 => dat_i,
      addr_i                => addr_i,
      tga_i                 => tga_i,
      we_i                  => we_i,
      stb_i                 => stb_i,
      cyc_i                 => cyc_i,
      dat_o                 => dat_o,
      rty_o                 => rty_o,
      ack_o                 => ack_o
   );

end rtl;