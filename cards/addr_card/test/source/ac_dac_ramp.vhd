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
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- no transmitter signals
      
      -- extended signals
--      dac_dat_o : out w_array11;
      
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
signal data     : word14;
signal idata    : integer;
signal idac     : integer;
signal ibus     : integer;
signal clkcount : std_logic;
signal nclk     : std_logic;
signal ramp     : std_logic := '0';
signal clk_2  : std_logic;
signal clk_div: integer;


signal logic0 : std_logic;
signal zero : integer;

begin

   zero <= 0;
   logic0 <= '0';

-- instantiate a counter to divide the clock by 8
   clk_div_2: counter
   generic map(MAX => 4,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => clk_i,
            rst_i   => '0',
            ena_i   => '1',
            load_i  => '0',
            count_i => 0 ,
            count_o => clk_div);

   clk_2   <= '1' when clk_div > 2 else '0'; -- slow down the 50MHz clock to 50/8MHz

-- instantiate a counter for idac to go through all 32 DACs
   data_count: counter
   generic map(MAX => 16#3fff#,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => clkcount,
            rst_i   => rst_i,
            ena_i   => ramp,
            load_i  => logic0,
            count_i => zero,
            count_o => idata);
  
   clkcount <= clk_2 when ramp = '1' else '0';
   nclk <= not (clkcount);
   
   gen1: for idac in 0 to 40 generate
      dac_clk_o(idac) <= nclk;
   end generate gen1;
   
   data <= conv_std_logic_vector(idata,14);
--   gen2: for ibus in 0 to 10 generate
--      dac_dat_o(ibus)  <= data;
--   end generate gen2;
   
   dac_dat0_o <= data;
   dac_dat1_o <= data;
   dac_dat2_o <= data;
   dac_dat3_o <= data;
   dac_dat4_o <= data;
   dac_dat5_o <= data;
   dac_dat6_o <= data;
   dac_dat7_o <= data;
   dac_dat8_o <= data;
   dac_dat9_o <= data;
   dac_dat10_o <= data;
      
   process(en_i)
   begin
      if(en_i = '1') then
         ramp <= not ramp;
      end if;
   end process;
   
   process(clk_2)
   begin
      if(clk_2'event and clk_2 = '1') then
         done_o <= en_i;
      end if;
   end process;
end;