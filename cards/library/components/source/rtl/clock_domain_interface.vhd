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
-- clock_domain_interface
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This module implements an interface for transferring data between clock
-- domains.  This module supports fast-to-slow and slow-to-fast transfers.
--
-- Note: this module only implements one-way handshaking between source and 
-- destination, ie. the tranfer can only happen from source to destination, 
-- not vice versa.  One will need to instantiate two clock_domain_interface 
-- modules in order to support two-way transfers.
--
-- Revision history:
-- 
-- $Log: clock_domain_interface.vhd,v $
-- Revision 1.1  2005/08/05 21:08:05  erniel
-- initial version
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity clock_domain_interface is
generic(DATA_WIDTH : integer := 32);
port(rst_i : in std_logic;

     src_clk_i : in std_logic;
     src_dat_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
     src_rdy_i : in std_logic;
     src_ack_o : out std_logic;
     
     dst_clk_i : in std_logic;
     dst_dat_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
     dst_rdy_o : out std_logic;
     dst_ack_i : in std_logic);
end clock_domain_interface;

architecture rtl of clock_domain_interface is
signal rdy       : std_logic;
signal rdy_sync1 : std_logic;
signal rdy_sync2 : std_logic;
signal rdy_temp  : std_logic;
signal rdy_pulse : std_logic;

signal ack       : std_logic;
signal ack_sync1 : std_logic;
signal ack_sync2 : std_logic;
signal ack_temp  : std_logic;

begin

   ---------------------------------------------------------
   -- Data Ready Signal Synchronization:
   ---------------------------------------------------------
   
   -- convert src_rdy pulse to rdy event:
   
   process(src_clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rdy <= '0';
      elsif(src_clk_i'event and src_clk_i = '1') then
         rdy <= (rdy and not src_rdy_i) or (not rdy and src_rdy_i);
      end if;
   end process;
   
   
   -- synchronize rdy to dst_clk domain:
   
   process(dst_clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rdy_sync1 <= '0';
         rdy_sync2 <= '0';
         rdy_temp  <= '0';
      elsif(dst_clk_i'event and dst_clk_i = '1') then
         rdy_sync1 <= rdy;
         rdy_sync2 <= rdy_sync1;
         rdy_temp  <= rdy_sync2;
      end if;
   end process;
   

   -- convert rdy event to dst_rdy pulse:

   dst_rdy_o <= rdy_temp xor rdy_sync2;
   

   ---------------------------------------------------------
   -- Data Acknowledge Signal Synchronization:
   ---------------------------------------------------------
      
   -- convert ack_pulse to ack event:
   
   process(dst_clk_i, rst_i)
   begin
      if(rst_i = '1') then
         ack <= '0';
      elsif(dst_clk_i'event and dst_clk_i = '1') then
         ack <= (ack and not dst_ack_i) or (not ack and dst_ack_i);
      end if;
   end process;
   
   
   -- synchronize ack to src_clk domain:
   
   process(src_clk_i, rst_i)
   begin
      if(rst_i = '1') then
         ack_sync1 <= '0';
         ack_sync2 <= '0';
         ack_temp  <= '0';
      elsif(src_clk_i'event and src_clk_i = '1') then
         ack_sync1 <= ack;
         ack_sync2 <= ack_sync1;
         ack_temp  <= ack_sync2;
      end if;
   end process;
   
   
   -- convert ack event to src_ack_pulse:
   
   src_ack_o <= ack_temp xor ack_sync2;
   
   
   ---------------------------------------------------------
   -- Data Synchronization:
   ---------------------------------------------------------
      
   -- connect the data straight through (handshaking takes care of synchronization):
   
   dst_dat_o <= src_dat_i;
   
end rtl;