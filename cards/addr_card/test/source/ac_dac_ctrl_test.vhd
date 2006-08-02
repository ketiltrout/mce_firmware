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
-- Project:       SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- This simple implementation loads a series of fixed values to 
-- series of parallel 14-bit 165MS/s DACs (AD9744)s.
-- A new value is loaded once en_i is asserted.
-- To add a new test value:
--     1. adjust the NUM_FIXED_VALUES constant 
--     2. add an entry to the data array
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity ac_dac_ctrl_test is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- no transmitter signals
      
      -- extended signals
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
      
      dac_clk_o : out std_logic_vector (40 downto 0)      
   );   
end;  

architecture rtl of ac_dac_ctrl_test is

constant NUM_FIXED_VALUES : integer := 16;

-- controller states:
type   array_vec is array (NUM_FIXED_VALUES-1 downto 0) of std_logic_vector (13 downto 0); 
signal data        : array_vec;
signal idat        : integer range 0 to NUM_FIXED_VALUES-1;
signal dac_clk     : std_logic;
signal dac_clk_1dly: std_logic;

begin
   
   load_next_data: process(clk_i, rst_i)         
   begin
      if (rst_i = '1') then
         idat <= 0;
      elsif (clk_i'event and clk_i = '1') then
         if (en_i = '1') then
           if (idat < NUM_FIXED_VALUES-1) then
             idat <= idat + 1;
           else
             idat <= 0;
           end if;
         end if;
      end if;
   end process load_next_data;
   
   gen_dac_clk: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
        dac_clk <= '0';
        dac_clk_1dly <= '0';
      elsif (clk_i'event and clk_i = '1') then
        dac_clk <= en_i;
        dac_clk_1dly <= dac_clk;
      end if;  
   end process gen_dac_clk; 
   
   dac_clk_o <= (others=> dac_clk_1dly);
   done_o <= dac_clk_1dly;
        
   data (0) <= "00000000000000";--x0000
   data (1) <= "00000000000001";--x0001
   data (2) <= "00000000000010";--x0002
   data (3) <= "00000000000100";--x0004
   data (4) <= "00000000001000";--x0008
   data (5) <= "00000000010000";--x0010
   data (6) <= "00000000100000";--x0020
   data (7) <= "00000001000000";--x0040
   data (8) <= "00000010000000";--x0080
   data (9) <= "00000100000000";--x0100
   data (10) <="00001000000000";--x0200
   data (11) <="00010000000000";--x0400
   data (12) <="00100000000000";--x0800
   data (13) <="01000000000000";--x1000
   data (14) <="10000000000000";--x2000
   data (15) <="11111111111111";--x3fff full scale

   
   dac_dat0_o <= data(idat);
   dac_dat1_o <= data(idat);
   dac_dat2_o <= data(idat);
   dac_dat3_o <= data(idat);
   dac_dat4_o <= data(idat);
   dac_dat5_o <= data(idat);
   dac_dat6_o <= data(idat);
   dac_dat7_o <= data(idat);
   dac_dat8_o <= data(idat);
   dac_dat9_o <= data(idat);
   dac_dat10_o <= data(idat);
               
      

   
 end;