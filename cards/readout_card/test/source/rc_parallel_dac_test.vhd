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
-- rc_parallel_dac_test file: It tests the serial DACs, 
-- if mode = 00, cycles through fixed values on the outputs
-- if mode = 01, then it puts a ramp on the ouputs of the DACs
-- if mode = 10, then it performs the square wave test.
--
--
-- Revision history:
-- <date $Date: 2004/07/21 22:29:29 $> - <initials $Author: erniel $>
-- $Log: rc_parallel_dac_test.vhd,v $
-- Revision 1.6  2004/07/21 22:29:29  erniel
-- updated counter component
--
-- Revision 1.5  2004/07/19 23:17:25  bench1
-- Mandana: deleted the left-over dac_clk_o and done_o assignments
--
-- Revision 1.4  2004/07/19 20:20:34  mandana
-- added square wave test for parallel DACs
--
-- Revision 1.3  2004/07/16 18:05:54  bench1
-- Mandana: more fixed values
--
-- Revision 1.2  2004/06/22 20:52:35  mandana
-- fixed synthesis errors
--
-- Revision 1.1  2004/06/12 01:03:07  mandana
-- Initial release
--
--
--
-----------------------------------------------------------------------------

library ieee, sys_param, components, work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

use components.component_pack.all;

use work.frame_timing_pack.all;

-----------------------------------------------------------------------------
                     
entity rc_parallel_dac_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      mode      : in std_logic_vector(1 downto 0);    -- mode: fix/ramp/xtalk
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals removed!
      -- extended signals
      dac0_dat_o  : out std_logic_vector(13 downto 0);
      dac1_dat_o  : out std_logic_vector(13 downto 0);
      dac2_dat_o  : out std_logic_vector(13 downto 0);
      dac3_dat_o  : out std_logic_vector(13 downto 0);
      dac4_dat_o  : out std_logic_vector(13 downto 0);
      dac5_dat_o  : out std_logic_vector(13 downto 0);
      dac6_dat_o  : out std_logic_vector(13 downto 0);
      dac7_dat_o  : out std_logic_vector(13 downto 0);
      
      dac_clk_o   : out std_logic_vector(7 downto 0)      
   );   
end;  

---------------------------------------------------------------------

architecture rtl of rc_parallel_dac_test_wrapper is

-- controller states:
type states is (IDLE, PUSH_DATA, CLKNOW, DONE); 
signal present_state         : states;
signal next_state            : states;
type   array_of_8_word14 is array (7 downto 0) of word14; 
signal fix     : array_of_8_word14;

signal idat     : integer;
signal idac     : integer;
signal clkcount : std_logic;
signal nclk     : std_logic;
signal idata    : integer;
signal ramp     : std_logic;
signal square   : std_logic;

signal data_fix : word14;
signal data_ramp: word14;
signal data_square: word14;
signal dac_clk_fix,  dac_clk_ramp, dac_clk_square: word8;
signal en_fix, en_ramp, en_square : std_logic;
signal done_fix, done_ramp, done_square  : std_logic;

signal clk_2    : std_logic;
signal clk_count: std_logic_vector(10 downto 0);

signal logic0 : std_logic;
signal logic1 : std_logic;
signal zero : integer;

begin
   logic0 <= '0';
   logic1 <= '1';
   zero <= 0;
   
   en_fix    <= en_i when mode = "00" else '0';
   en_ramp   <= en_i when mode = "01" else '0';
   en_square <= en_i when mode = "10" else '0';
   
   with mode select
      dac0_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
   with mode select
      dac1_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
   with mode select
      dac2_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
   with mode select
      dac3_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
   with mode select
      dac4_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
   with mode select
      dac5_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
   with mode select
      dac6_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
   with mode select
      dac7_dat_o <= data_ramp   when "01", 
                    data_square when "10",
                    data_fix    when others;
                 
   with mode select
      dac_clk_o <=  dac_clk_ramp   when "01", 
                    dac_clk_square when "10",
                    dac_clk_fix    when others;
   with mode select
      done_o   <=   done_ramp   when "01", 
                    done_square when "10",
                    done_fix    when others;
    
   ramp_data_count: counter
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
  
   clkcount <= clk_i when ramp = '1' else '0';
   nclk <= not (clkcount);
   
   dac_clk_ramp <= (others => nclk);
   data_ramp <= conv_std_logic_vector(idata,14);
   
   process(en_ramp)
   begin
      if(en_ramp = '1') then
         ramp <= not ramp;
      end if;
   end process;
 
   -------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         clk_count <= (others =>'0');
      elsif(clk_i'event and clk_i = '1') then
         clk_count <= clk_count + 1;
      end if;
   end process;

   clk_2 <= clk_count(6);
   
   process(en_square)
   begin
      if(en_square = '1') then
         square <= not(square);
      end if;
   end process;
   data_square <= (others => clk_2) when square = '1' else (others => '0');
   dac_clk_square <= (others => nclk);
-----------------------------------------------------------
   fix_data_count: counter
   generic map(MAX => 7,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => en_i,
            rst_i   => rst_i,
            ena_i   => logic1,
            load_i  => logic0,
            count_i => zero ,
            count_o => idat);
            
   -- test DACs for fixed values, single bit on LSBs and full scale
   -- If you add new values, make sure you adjust the MAX for data_count counter and array size for data!
   fix (0) <= "00000000000000";--x0000
   fix (1) <= "00000000000001";--x0001
   fix (2) <= "00000000000010";--x0002
   fix (3) <= "00000000000100";--x0004
   fix (4) <= "00000000001000";--x0008
   fix (5) <= "00000000010000";--x0010
   fix (6) <= "00000000100000";--x0020
   fix (7) <= "11111111111111";--x3fff full scale

  -- state register:
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
         done_ramp <= en_ramp;
         done_square <= en_square;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state, en_fix)
   begin
      case present_state is
         when IDLE =>     
            if(en_fix = '1') then
               next_state <= PUSH_DATA;
            else
               next_state <= IDLE;
            end if;
                
         when PUSH_DATA =>  
            next_state  <= CLKNOW; -- 2ns settling time for data (ts)
            
         when CLKNOW =>
            next_state  <= DONE;
         
         when DONE =>
            next_state  <= IDLE;
                        
      end case;
   end process state_NS;
-----------------------------------------------------------------   
   state_out: process(present_state)
   begin
      case present_state is
         when IDLE =>        
            data_fix <= "00000000000000";   
            dac_clk_fix <= (others => '0');
       done_fix    <= '0';
         
         when PUSH_DATA =>    
            data_fix <= fix(idat);           
            dac_clk_fix <= (others => '0');
       done_fix    <= '0';
                          
         when CLKNOW =>    
            data_fix <= fix(idat);
            dac_clk_fix <= (others => '1');
       done_fix    <= '0';

          when DONE =>    
            data_fix <= "00000000000000";
            dac_clk_fix <= (others => '0');
       done_fix    <= '1';
                                 
      end case;
   end process state_out;
   

   end;
 

