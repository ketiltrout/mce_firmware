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
-- adc_ctrl.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Analog-to-Digital converter control
--
-- Revision history:
-- 
-- $Log: adc_ctrl.vhd,v $
-- Revision 1.1  2004/06/19 03:54:53  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

entity adc_ctrl is
port(clk_i : in std_logic;
     rst_i : in std_logic;
     
     adc_dat_i : in std_logic_vector(13 downto 0);
     adc_ovr_i : in std_logic;
     adc_rdy_i : in std_logic;
     adc_clk_o : out std_logic;
     
     dat_o : out std_logic_vector(13 downto 0));
end adc_ctrl;

architecture behav of adc_ctrl is
begin
   
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         dat_o <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(adc_rdy_i = '1') then
            dat_o <= adc_dat_i;
         end if;
      end if;
   end process;
   
end behav;