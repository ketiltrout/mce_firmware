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

-- sram.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- VHDL model of asynch. SRAM chip
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sram is
port(address : in std_logic_vector(19 downto 0);
     data    : inout std_logic_vector(15 downto 0);
     n_bhe   : in std_logic;
     n_ble   : in std_logic;
     n_oe    : in std_logic;
     n_we    : in std_logic;
     n_ce1   : in std_logic;
     ce2     : in std_logic);
end sram;

architecture behav of sram is
type mem is array(1048575 downto 0) of std_logic_vector(15 downto 0);
signal sram_mem : mem;
begin

   process(address, data, n_bhe, n_ble, n_oe, n_we, n_ce1, ce2)
   begin
      if(ce2 = '1' and n_ce1 = '0') then
         if(n_we = '1') then
            if(n_bhe = '0' and n_ble = '0') then
               data <= sram_mem(conv_integer(address));
            else
               data <= (others => 'Z');
            end if;
         else
            if(n_oe = '0') then
               if(n_bhe = '0' and n_ble = '0') then
                  sram_mem(conv_integer(address)) <= data;
               end if;
            end if;
         end if;
      end if;
   end process;
   
end behav;