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

-- <Title>
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_COUNTER is
end TB_COUNTER;

architecture BEH of TB_COUNTER is

   component COUNTER

      generic(MAX   : integer  := 255 );

      port(CLK_I     : in std_logic ;
           RST_I     : in std_logic ;
           ENA_I     : in std_logic ;
           LOAD_I    : in std_logic ;
           DOWN_I    : in std_logic ;
           COUNT_I   : in integer ;
           COUNT_O   : out integer );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK_I     : std_logic := '1';
   signal W_RST_I     : std_logic ;
   signal W_ENA_I     : std_logic ;
   signal W_LOAD_I    : std_logic ;
   signal W_DOWN_I    : std_logic ;
   signal W_COUNT_I   : integer ;
   signal W_COUNT_O   : integer ;

begin

   DUT : COUNTER

      generic map(MAX   => 255 )

      port map(CLK_I     => W_CLK_I,
               RST_I     => W_RST_I,
               ENA_I     => W_ENA_I,
               LOAD_I    => W_LOAD_I,
               DOWN_I    => W_DOWN_I,
               COUNT_I   => W_COUNT_I,
               COUNT_O   => W_COUNT_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
   begin

      -- reset, count up for 10 clocks:
      W_RST_I     <= '1';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '0';
      W_COUNT_I   <= 0;
      wait for PERIOD;
      W_RST_I     <= '0';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '0';
      W_COUNT_I   <= 0;
      wait for PERIOD*10;
      
      -- reset, count down for 10 clocks:
      W_RST_I     <= '1';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '1';
      W_COUNT_I   <= 0;
      wait for PERIOD;
      W_RST_I     <= '0';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '1';
      W_COUNT_I   <= 0;
      wait for PERIOD*10;
      
      -- don't reset, just synchronously load new value and count down for 10 clocks:
      W_RST_I     <= '0';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '1';
      W_DOWN_I    <= '1';
      W_COUNT_I   <= 43;
      wait for PERIOD;
      W_RST_I     <= '0';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '1';
      W_COUNT_I   <= 0;
      wait for PERIOD*10;
      
      -- disable counter:
      W_RST_I     <= '0';
      W_ENA_I     <= '0';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '1';
      W_COUNT_I   <= 0;
      wait for PERIOD*5;
      
      -- enable counter, count up again:
      W_RST_I     <= '0';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '0';
      W_COUNT_I   <= 0;
      wait for PERIOD*10;
      
      -- reset, count past upper limit:
      W_RST_I     <= '1';
      W_ENA_I     <= '0';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '1';
      W_COUNT_I   <= 0;
      wait for PERIOD;
      W_RST_I     <= '0';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '0';
      W_COUNT_I   <= 0;
      wait for PERIOD*2;
      
      -- count down past lower limit:
      W_RST_I     <= '0';
      W_ENA_I     <= '1';
      W_LOAD_I    <= '0';
      W_DOWN_I    <= '1';
      W_COUNT_I   <= 0;
      wait for PERIOD*3;
      wait;
   end process STIMULI;

end BEH;