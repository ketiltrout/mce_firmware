-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- tb_init_fsm.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	     SCUBA-2
-- Author:	      Ernie Lin
-- Organisation:	UBC
--
-- Description:
-- Testbench for the initialization phase of the 1-wire bus communication
--
-- Revision history:
-- Jan. 16 2004  - Initial version      - EL
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_INIT_1_WIRE is
end TB_INIT_1_WIRE;

architecture BEH of TB_INIT_1_WIRE is

   component INIT_1_WIRE
      port(CLK            : in std_logic ;
           RST            : in std_logic ;
           INIT_START_I   : in std_logic ;
           INIT_DONE_O    : out std_logic ;
           DATA_BI        : inout std_logic );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK            : std_logic  := '0';
   signal W_RST            : std_logic ;
   signal W_INIT_START_I   : std_logic ;
   signal W_INIT_DONE_O    : std_logic ;
   signal W_DATA_BI        : std_logic ;

begin

   DUT : INIT_1_WIRE
      port map(CLK            => W_CLK,
               RST            => W_RST,
               INIT_START_I   => W_INIT_START_I,
               INIT_DONE_O    => W_INIT_DONE_O,
               DATA_BI        => W_DATA_BI);

   W_CLK <= not W_CLK after PERIOD/2;

   STIMULI : process
   begin
      W_DATA_BI        <= 'H';
      
      W_RST            <= '1';
      W_INIT_START_I   <= '0';
      wait for PERIOD;

      W_RST            <= '0';
      W_INIT_START_I   <= '1';
      wait for PERIOD;
      
      W_RST            <= '0';
      W_INIT_START_I   <= '0';
      wait for 510 us;
      
      wait for 15 us;
      
      W_DATA_BI        <= '0';
      W_RST            <= '0';
      W_INIT_START_I   <= '0';
      wait for 60 us;
      
      W_DATA_BI        <= 'H';
      
      wait for PERIOD;
      
      wait until W_INIT_DONE_O = '1';     
      assert false report "Test 1: completed";
      wait for PERIOD*10;
      
      W_RST            <= '1';
      W_INIT_START_I   <= '0';
      wait for PERIOD;

      W_RST            <= '0';
      W_INIT_START_I   <= '1';
      wait for PERIOD;
      
      W_RST            <= '0';
      W_INIT_START_I   <= '0';
      wait for 510 us;
      
      wait for 510 us;
      
      assert false report "Test 2: completed";
      
      wait;
   end process STIMULI;

end BEH;

