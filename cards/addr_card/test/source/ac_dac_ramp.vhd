-- 2003 SCUBA-2 Project
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

-- ac_dac_ctrl_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- NOTE: THIS IS A SIMPLE implementation to make a ramp signal on the DAC outputs
--       once enable is received.
-- 
--  
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.data_types_pack.all;

library components;
use components.component_pack.all;


entity ac_dac_ramp is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      clk_4_i   : in std_logic;    -- clock-div-4 input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- no transmitter signals
      
      -- extended signals=    
      dac_dat0_o  : out std_logic_vector(13 downto 0);
      dac_dat1_o  : out std_logic_vector(13 downto 0);
      dac_dat2_o  : out std_logic_vector(13 downto 0);
      dac_dat3_o  : out std_logic_vector(13 downto 0);
      dac_dat4_o  : out std_logic_vector(13 downto 0);
      dac_dat5_o  : out std_logic_vector(13 downto 0);
      dac_dat6_o  : out std_logic_vector(13 downto 0);
      dac_dat7_o  : out std_logic_vector(13 downto 0);
      dac_dat8_o  : out std_logic_vector(13 downto 0);
      dac_dat9_o  : out std_logic_vector(13 downto 0);
      dac_dat10_o : out std_logic_vector(13 downto 0);
      
      dac_clk_o   : out std_logic_vector(40 downto 0) );   
end;  

architecture rtl of ac_dac_ramp is

-- DAC CTRL:
-- State encoding and state variables:

-- controller states:
signal data_ramp: std_logic_vector(13 downto 0);

signal idac     : integer range 0 to 40;
signal clkcount : std_logic;
signal nclk     : std_logic;
signal ramp     : std_logic := '0';

begin

   ramp_data_count: process(rst_i, clk_4_i)
   begin
      if(rst_i = '1') then
         data_ramp <= (others => '0');
      elsif(clk_4_i'event and clk_4_i = '1') then
         if (ramp = '1') then
            data_ramp <= data_ramp + 1;
         end if;   
      end if;
   end process;
   
   clkcount <= clk_4_i when ramp = '1' else '0';
   nclk <= not (clkcount);
    
   -- ramp mode
   process(en_i)
   begin      
      --if (clk_i'event and clk_i = '1') then
         if(en_i = '1') then
            ramp <= not ramp;
         end if;
      --end if;   
   end process;
   
   gen1: for idac in 0 to 40 generate
      dac_clk_o(idac) <= nclk;
   end generate gen1;
   
   dac_dat0_o <= data_ramp;
   dac_dat1_o <= data_ramp;
   dac_dat2_o <= data_ramp;
   dac_dat3_o <= data_ramp;
   dac_dat4_o <= data_ramp;
   dac_dat5_o <= data_ramp;
   dac_dat6_o <= data_ramp;
   dac_dat7_o <= data_ramp;
   dac_dat8_o <= data_ramp;
   dac_dat9_o <= data_ramp;
   dac_dat10_o <= data_ramp;
      
   
   process(clk_i)
   begin
      if(clk_i'event and clk_i = '1') then
         done_o <= en_i;
      end if;
   end process;
end;