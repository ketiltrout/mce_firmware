---------------------------------------------------------------------
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
-- Project:       SCUBA-2
-- Author:        Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- bc_sa_htr_test applies a complementary square wave to the sa_htr output pair
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$ 
-----------------------------------------------------------------------------

library ieee, sys_param, components, work;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

use components.component_pack.all;

-----------------------------------------------------------------------------
                     
entity bc_sa_htr_test is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      pos_o     : out std_logic;
      neg_o     : out std_logic
      
   );   
end;  

---------------------------------------------------------------------

architecture rtl of bc_sa_htr_test is

signal clk_2    : std_logic;
signal clk_count: std_logic_vector(10 downto 0);
signal done     : std_logic;
signal toggle   : std_logic;
signal active   : std_logic := '0';

begin

   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         clk_count <= (others =>'0');
      elsif(clk_i'event and clk_i = '1') then
         clk_count <= clk_count + 1;
      end if;
   end process;

   clk_2 <= clk_count(9);
   pos_o <= toggle when active = '1' else '0';
   neg_o <= not toggle when active = '1' else '1';      

   process(en_i, clk_i, rst_i)
   begin
      if (rst_i = '1') then
        active <= '0';
        done_o <= '0';
      elsif (clk_i'event and clk_i = '1') then
        if(en_i = '1') then
           active <= not active;
        end if;
        done_o <= en_i;         
      end if;  
   end process;
    
   process(clk_2, rst_i)
   begin
      if (rst_i = '1') then
         toggle <= '0';
      elsif(clk_2'event and clk_2 = '1') then
         toggle <= not toggle;         
      end if;
   end process;

 end;
 

