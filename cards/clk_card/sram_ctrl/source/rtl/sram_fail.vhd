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
-- <revision control keyword substitutions e.g. $Id: sram_fail.vhd,v 1.1 2004/03/23 20:13:07 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- VHDL model of asynch. SRAM chip
--
-- Revision history:
-- <date $Date: 2004/03/23 20:13:07 $>	-		<text>		- <initials $Author: erniel $>
-- $Log: sram_fail.vhd,v $
-- Revision 1.1  2004/03/23 20:13:07  erniel
-- Initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sram_fail is
port(address : in std_logic_vector(19 downto 0);
     data    : inout std_logic_vector(15 downto 0);
     n_bhe   : in std_logic;
     n_ble   : in std_logic;
     n_oe    : in std_logic;
     n_we    : in std_logic;
     n_ce1   : in std_logic;
     ce2     : in std_logic;
     reset   : in std_logic);
end sram_fail;

architecture behav of sram_fail is
type mem is array(7 downto 0) of std_logic_vector(15 downto 0);
signal sram_mem : mem;

signal data_in  : std_logic_vector(15 downto 0);
signal data_out : std_logic_vector(15 downto 0);

signal write : std_logic;

begin

   -- read process:
   process(n_ce1, ce2, n_oe, n_we, n_bhe, n_ble, data_out)
   begin
      if(n_ce1 = '0' and ce2 = '1' and n_oe = '0' and n_we = '1' and n_bhe = '0' and n_ble = '0') then
         data <= data_out;
      else
         data <= (others => 'Z');
      end if;
   end process;
   
   -- write process:
   process(n_ce1, ce2, n_we, n_bhe, n_ble, data)
   begin
      if(n_ce1 = '0' and ce2 = '1' and n_we = '0' and n_bhe = '0' and n_ble = '0') then
         data_in <= data;
         write <= '1';
      else
         data_in <= (others => 'Z');
         write <= '0';
      end if;
   end process;
   
   -- memory array:
   process(reset, address, data_in)
   begin
      if(reset = '1') then 
         sram_mem(0) <= (others => '0');
         sram_mem(1) <= (others => '0');
         sram_mem(2) <= (others => '0');
         sram_mem(3) <= (others => '0');
         sram_mem(4) <= (others => '0');
         sram_mem(5) <= (others => '0');
         sram_mem(6) <= (others => '0');
         sram_mem(7) <= (others => '0');
      else
         if(write = '1') then
            case address(2 downto 0) is
               when "000"  => sram_mem(0) <= data_in;
               when "001"  => sram_mem(1) <= data_in;
               when "010"  => sram_mem(2) <= data_in;
               when "011"  => sram_mem(3) <= (data_in(15 downto 5) & '1' & data_in(3 downto 0));
               when "100"  => sram_mem(4) <= data_in;
               when "101"  => sram_mem(5) <= data_in;
               when "110"  => sram_mem(6) <= data_in;
               when "111"  => sram_mem(7) <= data_in;
               when others => null;
            end case;
         else
            case address(2 downto 0) is
               when "000"  => data_out <= sram_mem(0);
               when "001"  => data_out <= sram_mem(1);    
               when "010"  => data_out <= sram_mem(2);
               when "011"  => data_out <= sram_mem(3);
               when "100"  => data_out <= sram_mem(4);
               when "101"  => data_out <= sram_mem(5);
               when "110"  => data_out <= sram_mem(6);
               when "111"  => data_out <= sram_mem(7);
               when others => data_out <= (others => 'Z');
            end case;
         end if;
      end if;
   end process;  
end behav;