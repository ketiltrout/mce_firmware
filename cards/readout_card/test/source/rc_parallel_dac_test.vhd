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
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- rc_parallel_dac_test file: It tests the serial DACs, 
-- if mode = 0, cycles through fixed values on the outputs
-- if mode = 1, then it puts a ramp on the ouputs of the DACs
-- if mode = 2, then it performs the cross-talk test.
--
--
-- Revision history:
-- <date $Date: 2004/06/22 20:52:35 $>	- <initials $Author: mandana $>
-- $Log: rc_parallel_dac_test.vhd,v $
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
use sys_param.frame_timing_pack.all;
use sys_param.data_types_pack.all;
use components.component_pack.all;

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
signal data_fix     : array_of_8_word14;

signal data_ramp: word14;
signal idat     : integer;
signal idac     : integer;
signal clkcount : std_logic;
signal nclk     : std_logic;
signal idata    : integer;
signal ramp     : std_logic;

signal dac0_dat_fix, dac0_dat_ramp: word14;
signal dac1_dat_fix, dac1_dat_ramp: word14;
signal dac2_dat_fix, dac2_dat_ramp: word14;
signal dac3_dat_fix, dac3_dat_ramp: word14;
signal dac4_dat_fix, dac4_dat_ramp: word14;
signal dac5_dat_fix, dac5_dat_ramp: word14;
signal dac6_dat_fix, dac6_dat_ramp: word14;
signal dac7_dat_fix, dac7_dat_ramp: word14;
signal dac_clk_fix,  dac_clk_ramp: word8;
signal en_fix,   en_ramp    : std_logic;
signal done_fix, done_ramp  : std_logic;

signal logic0 : std_logic;
signal logic1 : std_logic;
signal zero : integer;

begin
   logic0 <= '0';
   logic1 <= '1';
   zero <= 0;
   
   en_fix  <= en_i when mode = "00" else '0';
   en_ramp <= en_i when mode = "01" else '0';
   
   dac0_dat_o <= dac0_dat_fix when mode = "00" else dac0_dat_ramp;
   dac1_dat_o <= dac1_dat_fix when mode = "00" else dac1_dat_ramp;
   dac2_dat_o <= dac2_dat_fix when mode = "00" else dac2_dat_ramp;
   dac3_dat_o <= dac3_dat_fix when mode = "00" else dac3_dat_ramp;
   dac4_dat_o <= dac4_dat_fix when mode = "00" else dac4_dat_ramp;
   dac5_dat_o <= dac5_dat_fix when mode = "00" else dac5_dat_ramp;
   dac6_dat_o <= dac6_dat_fix when mode = "00" else dac6_dat_ramp;
   dac7_dat_o <= dac7_dat_fix when mode = "00" else dac7_dat_ramp;

   dac_clk_o <= dac_clk_fix when mode = "00" else dac_clk_ramp;
   
   done_o <= done_fix when mode = "00" else done_ramp;
   
   ramp_data_count: counter
   generic map(MAX => 16#3fff#)
   port map(clk_i   => clkcount,
            rst_i   => rst_i,
            ena_i   => ramp,
            load_i  => logic0,
            down_i  => logic0,
            count_i => zero,
            count_o => idata);
  
   clkcount <= clk_i when ramp = '1' else '0';
   nclk <= not (clkcount);
   
   gen1: for idac in 0 to 7 generate
      dac_clk_ramp(idac) <= nclk;
   end generate gen1;
   
   data_ramp <= conv_std_logic_vector(idata,14);
   
   dac0_dat_ramp <= data_ramp;
   dac1_dat_ramp <= data_ramp;
   dac2_dat_ramp <= data_ramp;
   dac3_dat_ramp <= data_ramp;
   dac4_dat_ramp <= data_ramp;
   dac5_dat_ramp <= data_ramp;
   dac6_dat_ramp <= data_ramp;
   dac7_dat_ramp <= data_ramp;

   process(en_ramp)
   begin
      if(en_ramp = '1') then
         ramp <= not ramp;
      end if;
   end process;
 

 fix_data_count: counter
   generic map(MAX => 7)
   port map(clk_i   => en_i,
            rst_i   => rst_i,
            ena_i   => logic1,
            load_i  => logic0,
            down_i  => logic0,
            count_i => zero ,
            count_o => idat);
            
   -- test DACs for fixed values, single bit on LSBs and full scale
   -- If you add new values, make sure you adjust the MAX for data_count counter and array size for data!
   data_fix (0) <= "00000000000000";--x0000
   data_fix (1) <= "00000000000001";--x0001
   data_fix (2) <= "00000000000010";--x0002
   data_fix (3) <= "00000000000100";--x0004
   data_fix (4) <= "00000000001000";--x0008
   data_fix (5) <= "00000000010000";--x0010
   data_fix (6) <= "00000000100000";--x0020
   data_fix (7) <= "11111111111111";--x3fff full scale

  -- state register:
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
         done_ramp <= en_ramp;
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
            dac0_dat_fix <= "00000000000000";
            dac1_dat_fix <= "00000000000000";
            dac2_dat_fix <= "00000000000000";
            dac3_dat_fix <= "00000000000000";
            dac4_dat_fix <= "00000000000000";
            dac5_dat_fix <= "00000000000000";
            dac6_dat_fix <= "00000000000000";
            dac7_dat_fix <= "00000000000000";
   
            for idac in 0 to 7 loop
               dac_clk_fix(idac) <= '0';
            end loop;
	    done_fix    <= '0';
         
         when PUSH_DATA =>    
            dac0_dat_fix <= data_fix(idat);
            dac1_dat_fix <= data_fix(idat);
            dac2_dat_fix <= data_fix(idat);
            dac3_dat_fix <= data_fix(idat);
            dac4_dat_fix <= data_fix(idat);
            dac5_dat_fix <= data_fix(idat);
            dac6_dat_fix <= data_fix(idat);
            dac7_dat_fix <= data_fix(idat);
            
            for idac in 0 to 7 loop
               dac_clk_fix(idac) <= '0';
            end loop;
	    done_fix    <= '0';
                          
         when CLKNOW =>    
            dac0_dat_fix <= data_fix(idat);
            dac1_dat_fix <= data_fix(idat);
            dac2_dat_fix <= data_fix(idat);
            dac3_dat_fix <= data_fix(idat);
            dac4_dat_fix <= data_fix(idat);
            dac5_dat_fix <= data_fix(idat);
            dac6_dat_fix <= data_fix(idat);
            dac7_dat_fix <= data_fix(idat);
            
            for idac in 0 to 7 loop
               dac_clk_fix(idac) <= '1';
            end loop;
	    done_fix    <= '0';

          when DONE =>    
            dac0_dat_fix <= "00000000000000";
            dac1_dat_fix <= "00000000000000";
            dac2_dat_fix <= "00000000000000";
            dac3_dat_fix <= "00000000000000";
            dac4_dat_fix <= "00000000000000";
            dac5_dat_fix <= "00000000000000";
            dac6_dat_fix <= "00000000000000";
            dac7_dat_fix <= "00000000000000";
            
            for idac in 0 to 7 loop
               dac_clk_fix(idac) <= '0';
            end loop;
	    done_fix    <= '1';
	                              
      end case;
   end process state_out;
   

   end;
 

