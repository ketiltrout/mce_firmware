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
-- binary_counter.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This module implements a generic binary counter.  It differs from the
-- counter.vhd already in the components library; binary_counter.vhd 
-- outputs a std_logic_vector whereas counter.vhd outputs integer.
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity binary_counter is
generic(WIDTH : integer range 2 to 64 := 8);
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     ena_i   : in std_logic;
     up_i    : in std_logic;
     load_i  : in std_logic;
     clear_i : in std_logic;
     count_i : in std_logic_vector(WIDTH-1 downto 0);
     count_o : out std_logic_vector(WIDTH-1 downto 0));
end binary_counter;

architecture behav of binary_counter is

signal count : std_logic_vector(WIDTH-1 downto 0);

begin

   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         count <= (others => '0');            -- reset counter to "000..00"
      elsif(clk_i'event and clk_i = '1') then
         if(ena_i = '1') then
            if(load_i = '1') then
               count <= count_i;              -- load new counter value
            elsif(clear_i = '1') then
               if(up_i = '1') then
                  count <= (others => '0');   -- clear the counter value to "000..00" when counting up...
               else
                  count <= (others => '1');   -- and "111..11" when counting down
               end if;
            elsif(up_i = '1') then
               count <= count + 1;            -- add 1 to count value when counting up...
            else
               count <= count - 1;            -- subtract 1 from count value when counting down
            end if;
         end if;
      end if;
   end process;
   
   count_o <= count;

end behav;         