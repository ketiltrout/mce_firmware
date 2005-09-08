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
-- ring_counter.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This module implements a generic ring counter.  If a Johnson counter is
-- desired, instantiate ring_counter with MODE parameter set to 1.
--
-- Revision history:
-- 
-- $Log: ring_counter.vhd,v $
-- Revision 1.1  2005/08/17 20:25:39  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ring_counter is
generic(WIDTH : integer range 2 to 64 := 8;
        MODE  : std_logic := '1');            -- Counter mode: 0 = Ring, 1 = Johnson
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     ena_i   : in std_logic;
     up_i    : in std_logic;
     load_i  : in std_logic;
     clear_i : in std_logic;
     count_i : in std_logic_vector(WIDTH-1 downto 0);
     count_o : out std_logic_vector(WIDTH-1 downto 0));
end ring_counter;

architecture behav of ring_counter is

signal count : std_logic_vector(WIDTH-1 downto 0);
signal count_fb : std_logic;

begin

   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         count(WIDTH-1) <= '1';
         count(WIDTH-2 downto 0) <= (others => '0');            -- reset counter to "000..01"
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then
            if(up_i = '1') then
               count(0) <= '1';                                 -- clear the counter value to "000..01" when counting up...
               count(WIDTH-1 downto 1) <= (others => '0');
            else
               count(WIDTH-1) <= '1';                           -- and "100..00" when counting down
               count(WIDTH-2 downto 0) <= (others => '0');   
            end if;            
         elsif(ena_i = '1') then
            if(load_i = '1') then
               count <= count_i;                                -- load new counter value
            elsif(up_i = '1') then
               count <= count(WIDTH-2 downto 0) & count_fb;     -- shift bits left when counting up...
            else
               count <= count_fb & count(WIDTH-1 downto 1);     -- shift bits right when counting down
            end if;
         end if;
      end if;
   end process;
   
   ring_feedback:    if MODE = '0' generate 
                        count_fb <= (count(WIDTH-1) and up_i) or (count(0) and not up_i);
                     end generate;
                     
   johnson_feedback: if MODE = '1' generate  
                        count_fb <= (not count(WIDTH-1) and up_i) or (not count(0) and not up_i);
                     end generate;
                     
   count_o <= count;
   
end behav;