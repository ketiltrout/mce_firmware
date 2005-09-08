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
-- grey_counter.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This module implements a generic grey code counter.
--
-- Revision history:
-- 
-- $Log: grey_counter.vhd,v $
-- Revision 1.1  2005/08/17 20:25:39  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity grey_counter is
generic(WIDTH : integer range 2 to 64 := 8);
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     ena_i   : in std_logic;
     up_i    : in std_logic;
     load_i  : in std_logic;
     clear_i : in std_logic;
     count_i : in std_logic_vector(WIDTH-1 downto 0);
     count_o : out std_logic_vector(WIDTH-1 downto 0));
end grey_counter;

architecture behav of grey_counter is

signal count_d : std_logic_vector(WIDTH-1 downto 0);
signal count_q : std_logic_vector(WIDTH-1 downto 0);

signal zero : std_logic_vector(WIDTH-2 downto 0);   -- zero(i) = '1' means count(i-1 downto 0) = "000..00"

signal dummy : std_logic;

begin
   
   -- the "dummy bit":
   process(clk_i, rst_i)
   variable temp : std_logic;
   begin
      if(rst_i = '1') then
         dummy <= '0';                              -- on counter reset, dummy bit to '0'
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then
            if(up_i = '1') then 
               dummy <= '0';                        -- on counter clear, dummy bit is '0' when counting up...
            else
               dummy <= '1';                        -- and '1' when counting down
            end if;            
         elsif(ena_i = '1') then
            if(load_i = '1') then
               temp := count_i(0);                  -- on counter load, dummy bit is bitwise xor of input bits
               for i in 1 to WIDTH-1 loop
                  temp := temp xor count_i(i);
               end loop;
               dummy <= temp;
            else
               dummy <= not dummy;                  -- otherwise, invert dummy bit on each rising edge
            end if;
         end if;
      end if;
   end process;
   
   
   -- equations below handle counter load, counter clear, and counter up/down functionality:
   
   -- bit 0 (LSB):
   count_d(0) <= (not load_i and (count_q(0) xor up_i xor dummy)) or (load_i and count_i(0));   
   zero(0)    <= '1';
      
      
   -- bits 1 through WIDTH-2:
   bits: for i in 1 to WIDTH-2 generate
   begin
      count_d(i) <= (not load_i and (count_q(i) xor (count_q(i-1) and zero(i-1) and not (up_i xor dummy)))) or (load_i and count_i(i));
      zero(i)    <= zero(i-1) and not count_q(i-1);
   end generate bits;
   
   
   -- bit WIDTH-1 (MSB):
   count_d(WIDTH-1) <= (not load_i and (count_q(WIDTH-1) xor (zero(WIDTH-2) and not (up_i xor dummy)))) or (load_i and count_i(WIDTH-1));
   
   
   -- counter register:
   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         count_q <= (others => '0');                -- reset counter to "000..00"
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then
            if(up_i = '1') then
               count_q <= (others => '0');
            else
               count_q(WIDTH-1) <= '1';
               count_q(WIDTH-2 downto 0) <= (others => '0');
            end if;
         elsif(ena_i = '1') then 
            count_q <= count_d;                     -- if counter is enabled, update counter
         end if;
      end if;
   end process;
   
   count_o <= count_q;

end behav;