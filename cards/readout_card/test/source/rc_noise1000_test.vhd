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
-- rc_noise1000_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Stand-alone test module for readout card. It samples at 50MHz, adds up 1000 samples and
-- then dumps the result on the mictor once every 1000 samples.
--
-- Revision history:
-- <date $Date: 2005/01/18 23:49:44 $>    - <initials $Author: bench1 $>
-- $Log: rc_noise1000_test.vhd,v $
-- Revision 1.8  2005/01/18 23:49:44  bench1
-- Mandana: fixed the signed summation
--
-- Revision 1.7  2005/01/18 22:01:16  mandana
-- changed to signed operation
--
-- Revision 1.6  2005/01/18 21:41:13  bench1
-- Mandana: Introduce N_SAMPLES to parameterize the number of samples, currently set to 200
--
-- Revision 1.5  2004/07/26 23:47:58  bench1
-- Mandana: swapped adc1_rdy on mictor
--
-- Revision 1.4  2004/07/23 23:18:00  bench1
-- Mandana: corrected the mictor bits
--
-- Revision 1.3  2004/07/23 19:22:38  mandana
-- reset nsample
--
-- Revision 1.2  2004/07/22 23:50:41  bench1
-- Mandana: sum is now calculated in the same process as nsample, but not working
--
-- Revision 1.1  2004/07/22 18:58:22  mandana
-- Initial release, sums up 1000 samples before dumping the result on mictor
--
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
--use ieee.numeric_std.all;

entity rc_noise1000_test is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk  : in std_logic;
      outclk : out std_logic;
                        
      -- rc serial dac interface
      dac_dat        : out std_logic_vector (7 downto 0); 
      dac_clk       : out std_logic_vector (7 downto 0);
      bias_dac_ncs   : out std_logic_vector (7 downto 0); 
      offset_dac_ncs : out std_logic_vector (7 downto 0); 

      -- rc parallel dac interface
      dac_FB1_dat    : out std_logic_vector (13 downto 0);
      dac_FB2_dat    : out std_logic_vector (13 downto 0);
      dac_FB3_dat    : out std_logic_vector (13 downto 0);
      dac_FB4_dat    : out std_logic_vector (13 downto 0);
      dac_FB5_dat    : out std_logic_vector (13 downto 0);
      dac_FB6_dat    : out std_logic_vector (13 downto 0);
      dac_FB7_dat    : out std_logic_vector (13 downto 0);
      dac_FB8_dat    : out std_logic_vector (13 downto 0);

      dac_FB_clk     : out std_logic_vector (7 downto 0);     
      
      -- rc ADC interface
      adc1_clk       : out std_logic;
      adc1_rdy       : in std_logic;
      adc1_ovr       : in std_logic;
      adc1_dat       : in std_logic_vector (13 downto 0);  
      
      adc2_clk       : out std_logic;
      adc2_rdy       : in std_logic;
      adc2_ovr       : in std_logic;
      adc2_dat       : in std_logic_vector (13 downto 0);  
      
      adc3_clk       : out std_logic;
      adc3_rdy       : in std_logic;
      adc3_ovr       : in std_logic;      
      adc3_dat       : in std_logic_vector (13 downto 0);  
      
      adc4_clk       : out std_logic;
      adc4_rdy       : in std_logic;
      adc4_ovr       : in std_logic;
      adc4_dat       : in std_logic_vector (13 downto 0);  
      
      adc5_clk       : out std_logic;
      adc5_rdy       : in std_logic;
      adc5_ovr       : in std_logic;
      adc5_dat       : in std_logic_vector (13 downto 0);  
      
      adc6_clk       : out std_logic;
      adc6_rdy       : in std_logic;
      adc6_ovr       : in std_logic;
      adc6_dat       : in std_logic_vector (13 downto 0);  
      
      adc7_clk       : out std_logic;
      adc7_rdy       : in std_logic;
      adc7_ovr       : in std_logic;
      adc7_dat       : in std_logic_vector (13 downto 0);  

      adc8_clk       : out std_logic;
      adc8_rdy       : in std_logic;
      adc8_ovr       : in std_logic;      
      adc8_dat       : in std_logic_vector (13 downto 0);  
                  
      --test pins
      smb_clk: out std_logic; 
      mictor : out std_logic_vector(31 downto 0));
end rc_noise1000_test;

architecture behaviour of rc_noise1000_test is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        c1 : out std_logic;
        e0 : out std_logic);
   end component;

   constant N_SAMPLES : integer := 256;   

   signal zero : std_logic;
   signal one : std_logic;
   
   signal clk : std_logic;  
   signal clk2: std_logic;
   signal nsample: integer := 0;
   signal sum    : std_logic_vector(23 downto 0);
   signal sum14  : std_logic_vector(13 downto 0);
   signal en     : std_logic := '0';
begin
   
   clk_gen : pll
      port map(inclk0 => inclk,
              c0 => clk,
              c1 => clk2,
              e0 => outclk);
   
   adc1_clk <= clk;
   adc2_clk <= clk;
   adc3_clk <= clk;
   adc4_clk <= clk;
   adc5_clk <= clk;
   adc6_clk <= clk;
   adc7_clk <= clk;
   adc8_clk <= clk;
   
   co_add: process(adc8_rdy, n_rst)
   begin
      if(n_rst = '1') then
         sum <= (others => '0');
         nsample <= 0;
      elsif(adc8_rdy'event and adc8_rdy = '1') then  
         case nsample  is
            when N_SAMPLES - 1 =>
               en <= '1';
               nsample <= nsample + 1;
               sum <= sum + adc8_dat;
               
            when N_SAMPLES =>   
               nsample <= 0;
               sum     <= (others => '0');
               en <= '0';

            when others  =>
               nsample <= nsample + 1;
               sum <= sum + adc8_dat;
               en <= '0';
               
         end case;  
       end if;
   end process co_add;
   
   mictor (14 downto 0) <= sum (23) & sum(21 downto 8);
--   mictor (14)          <= clk;
--   mictor (15)          <= adc8_rdy;
--   mictor (15)          <= en;
   mictor (16)          <= adc8_rdy;
   mictor (30)          <= en;
   mictor (31)          <= adc8_rdy and en;

end behaviour;
