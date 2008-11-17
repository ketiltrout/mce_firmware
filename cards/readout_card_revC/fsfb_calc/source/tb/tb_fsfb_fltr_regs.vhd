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
-- tb_fsfb_fltr_regs.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Testbench for the first stage feedback filter wn registers.
-- The testbench does 2 pass of all addresses to make sure wn 
-- values are propagated all the way to wn2 registers.
-- This testbench works with the version of fsfb_fltr_regs that is 
-- implemented using altsyncram, initialize_window is not excerised 
-- automatically!
--
--
-- Revision history:
-- <date $Date: 2006/03/06 23:26:09 $>    - <initials $Author: mandana $>
-- $Log: tb_fsfb_fltr_regs.vhd,v $
-- Revision 1.2  2006/03/06 23:26:09  mandana
-- modified for 4-pole filter to include wn terms for 2 biquads
--
-- Revision 1.1  2005/11/29 22:32:20  mandana
-- Initial release
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fsfb_calc_pack.all;


entity tb_fsfb_fltr_regs is

end tb_fsfb_fltr_regs;

architecture test of tb_fsfb_fltr_regs is
   -- constant/signal declarations

   constant clk_period              : time      := 20 ns;   -- 50 MHz clock period
   shared variable endsim           : boolean   := false;   -- simulation window

   signal rst                       : std_logic := '1';     -- global reset

   -- ram interface
   signal data1_i                   : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
   signal data2_i                   : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);   
   signal addr_i                    : std_logic_vector(5 downto 0);
   signal wraddr_i                  : std_logic_vector(5 downto 0);
   signal rdaddr_i                  : std_logic_vector(5 downto 0);
   signal wren_i                    : std_logic;
   signal clk_i                     : std_logic := '0';
   signal slow_clk_i                : std_logic := '0';
   signal wn11_o                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
   signal wn12_o                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
   signal wn21_o                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
   signal wn22_o                    : std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
   
   -- initialize_window if '1' for full frame, it would initialize all wn1 and wn2 entries to 0
   signal init_i                    : std_logic := '0';
   
   -- done signals
   signal wr_done                   : std_logic := '1';
   signal rd_done                   : std_logic;
   signal first_round_done          : std_logic;
   signal n                         : integer range 0 to 5 := 0; -- number of cycles all 41 registers are written/read
   signal count                     : integer range 0 to 8;

begin

   rst <= '0' after 10 * clk_period;
   
   -- Generate a 50MHz clock (ie 20 ns period)
   clk_gen : process
   begin
      if endsim = false then
         clk_i <= not clk_i;
         wait for clk_period/2;
      else
         wait;
      end if;
   end process clk_gen;
      
   clk_divider: process (clk_i, rst)
   begin 
      if (rst = '1') then
         count <= 0;
         
      elsif (clk_i'event and clk_i = '1') then
         if (count > 4) then
           count <= 0;           
         else
           count <= count + 1;
         end if;
         
      end if;
   end process clk_divider;
   slow_clk_i <= '0' when count < 3 else '1';
   
 -- Write read operation control
   -- The RAM content is 1, 3, 5,... in the first pass and 2,4,6, ... in the second pass
   addr_gen : process(slow_clk_i, rst)
   begin
      if rst = '1' then
         wraddr_i <= (others => '1');
         rdaddr_i <= (0 => '0', others => '1'); 
         data1_i  <= (others => '1');
         data2_i  <= (others => '1');
            
      elsif (slow_clk_i'event and slow_clk_i = '1') then         
         if (first_round_done) = '0' then
           wraddr_i <= wraddr_i + 1;
           rdaddr_i <= rdaddr_i + 1;
           data1_i  <= data1_i + 2;
           data2_i  <= data2_i + 5;
         else
           wraddr_i <= (others => '1');
           rdaddr_i <= (0 => '0', others => '1'); 
           data1_i  <= (others => '0');
           data2_i  <= (others => '0');
         end if;  
      end if;
   end process addr_gen;
   
   wren_i <= '1' when count = 0 else '0';
   
   addr_i <= wraddr_i ;--when wren_i = '1' else rdaddr_i;
    
   -- Simulation ends after 2 pass over all addresses to make sure wn propagtes to wn2
   process (wraddr_i)
   begin
      if wraddr_i = 41 then
           first_round_done <= '1';        
           n <= n + 1;
      else
        first_round_done <= '0';
      end if;

      -- end the simulation
      if n = 3 then 
        endsim := true;
      end if;
   end process;
      
      
   -- unit under test:  first stage feedback filter registers
   UUT : fsfb_fltr_regs 
      port map (
         rst_i                    => rst,
         clk_50_i                 => clk_i,
         fltr_rst_i               => init_i,
         addr_i                   => addr_i,
         wn12_o                   => wn12_o,
         wn11_o                   => wn11_o,
         wn10_i                   => data1_i,
         wn22_o                   => wn22_o,
         wn21_o                   => wn21_o,
         wn20_i                   => data2_i,         
         wren_i                   => wren_i
      );
   

end test;

