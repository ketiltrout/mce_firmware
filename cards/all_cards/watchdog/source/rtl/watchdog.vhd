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
-- <revision control keyword substitutions e.g. $Id: watchdog.vhd,v 1.5 2004/04/21 20:02:34 bburger Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC
--
-- Description:
-- This file implements the watchbone reset functionality
--
-- Revision history:
-- <date $Date: 2004/04/21 20:02:34 $>	-		<text>		- <initials $Author: bburger $>
-- $Log: watchdog.vhd,v $
-- Revision 1.5  2004/04/21 20:02:34  bburger
-- Changed address moniker
--
-- Revision 1.4  2004/04/08 18:41:37  erniel
-- removed watchdog controller block
-- removed slave controller interface block
-- simplified timer reset logic
-- renamed signals
-- removed obsolete signals
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

-- contains slave_ctrl, us_timer and counter
library components;
use components.component_pack.all;


entity watchdog is
   generic (
      ADDR_WIDTH : integer := WB_ADDR_WIDTH;
      DATA_WIDTH : integer := WB_DATA_WIDTH;
      TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
   );
   port (   
      -- Wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;		
      dat_i 	 : in std_logic_vector (DATA_WIDTH-1 downto 0); 
      addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
      rty_o   : out std_logic;
      ack_o   : out std_logic;
      
      you_kick_my_dog : out std_logic
   );
end watchdog;

architecture rtl of watchdog is

signal wb_timer      : integer;
signal wdt_timer     : integer;
signal wb_timer_rst  : std_logic;
signal wdt_timer_rst : std_logic;

constant WB_TIMER_LIMIT  : integer := 5000000; -- us, after 5 s, do not allow watchdog to be reset
constant WDT_TIMER_LIMIT : integer := 180000;  -- us, reset watchdog every 180 ms (watchdog times out at 200 ms).

begin
     
------------------------------------------------------------
--
-- Instantiate timers
--
------------------------------------------------------------

   wishbone_timer : us_timer
   port map (
      clk => clk_i,
      timer_reset_i => wb_timer_rst,
      timer_count_o => wb_timer  
   );
   
   watchdog_timer : us_timer
   port map (
      clk => clk_i,
      timer_reset_i => wdt_timer_rst,
      timer_count_o => wdt_timer  
   );
   
   
------------------------------------------------------------
--
-- Timer reset and output logic
--
------------------------------------------------------------

   wb_timer_rst  <= '1' when (rst_i = '1' or (addr_i = RST_WTCHDG_ADDR and stb_i = '1' and cyc_i = '1')) else '0';
   wdt_timer_rst <= '1' when (rst_i = '1' or (wdt_timer = WDT_TIMER_LIMIT)) else '0';
   
   you_kick_my_dog <= '1' when (wdt_timer = WDT_TIMER_LIMIT and wb_timer < WB_TIMER_LIMIT) else '0';
   
      
------------------------------------------------------------
--
-- Wishbone section
--
------------------------------------------------------------
  
   rty_o <= '0';
   ack_o <= '1' when (addr_i = RST_WTCHDG_ADDR and stb_i = '1' and cyc_i = '1') else '0';

end rtl;