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
-- rc_serial_dac_test file: It tests the serial DACs, 
-- if mode = 0, cycles through fixed values on the outputs
-- if mode = 1, then it puts a ramp on the ouputs of the DACs
-- if mode = 2, then it performs the cross-talk test.(in future)
--
--
-- Revision history:
-- <date $Date: 2004/12/07 22:11:56 $> - <initials $Author: bench2 $>
-- $Log: rc_serial_dac_test.vhd,v $
-- Revision 1.8  2004/12/07 22:11:56  bench2
-- mandana: frame timing commented, not used
-- The full range fix value commented for subrack test
--
-- Revision 1.7  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.6  2004/07/21 22:26:24  erniel
-- updated counter component
--
-- Revision 1.5  2004/07/16 18:06:12  bench1
-- Mandana: less fixed values
--
-- Revision 1.4  2004/07/16 00:15:38  bench1
-- Mandana: changed en_ramp to ramp in IDLE state to run continous ramp
--
-- Revision 1.3  2004/07/15 17:57:09  bench1
-- Mandana: dac_data_p wouldn't hold during state changes again, had to fix
--
-- Revision 1.2  2004/06/22 20:52:45  mandana
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

--use work.frame_timing_pack.all;

-----------------------------------------------------------------------------
                     
entity rc_serial_dac_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      clk_4_i   : in std_logic;    -- spi clock input
      en_i      : in std_logic;    -- enable signal
      mode      : in std_logic_vector(1 downto 0);    -- mode: fix/ramp/xtalk
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals removed!
      -- extended signals
      dac_dat_o : out std_logic_vector (7 downto 0); 
      dac_ncs_o : out std_logic_vector (7 downto 0); 
      dac_clk_o : out std_logic_vector (7 downto 0)
   );   
end;  

---------------------------------------------------------------------

architecture rtl of rc_serial_dac_test_wrapper is

-- State encoding and state variables:
-- controller states:
type states is (IDLE, PUSH_DATA_FIX, PUSH_DATA_RAMP, SPI_START, DONE); 

signal present_state         : states;
signal next_state            : states;

type   w_array3 is array (2 downto 0) of word16; 
type   w_array8 is array (7 downto 0) of word16; 
signal data     : w_array8;

signal idac     : integer;
signal idx      : integer;
signal send_dac_start: std_logic;
signal dac_done : std_logic_vector (7 downto 0);
signal en_fix   : std_logic;
signal en_ramp  : std_logic;
signal ramp     : std_logic := '0';
signal spi_rdy : std_logic;
signal ramp_data_count_en : std_logic;
signal fix_data_count_en  : std_logic;

signal idata    : integer;

signal logic0   : std_logic;
signal logic1   : std_logic;
signal ramp_data: std_logic_vector(15 downto 0);
signal done_fix : std_logic;
signal done_ramp: std_logic;
signal en_slow  : std_logic;

-- parallel data signals for DAC
signal dac_data_p      : w_array8;

begin

   en_fix  <= en_slow when mode = "00" else '0';
   en_ramp <= en_slow when mode = "01" else '0';

-- instantiate a counter for generating ramp
   ramp_data_count: counter
   generic map(MAX => 16#ffff#,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => clk_4_i,
            rst_i   => rst_i,
            ena_i   => ramp_data_count_en,
            load_i  => '0',
            count_i => 0,
            count_o => idata);
   
   ramp_data_count_en  <= ramp and spi_rdy;

   next_dac_value: process(clk_4_i, rst_i)
   begin
      if(rst_i = '1') then 
         spi_rdy <= '1';
      elsif(clk_4_i'event and clk_4_i = '1') then
         if ( dac_done(0) = '1') then
           spi_rdy <= '1';
         else
           spi_rdy <= '0';
         end if;
      end if;
   end process next_dac_value;
   
   ramp_data <= conv_std_logic_vector(idata,16);
     
-- instantiate a counter for idx to go through different values    
   idx_count: counter
   generic map(MAX => 7,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => clk_4_i,
            rst_i   => '0', -- '0' or rst_i? think!!!!!
            ena_i   => fix_data_count_en,
            load_i  => '0',
            count_i =>  0,
            count_o => idx);
            
   clk_domain_crosser : fast2slow_clk_domain_crosser
      generic map (
         NUM_TIMES_FASTER            => 4
      )
         
      port map (
         rst_i                       => rst_i,
         clk_slow                    => clk_4_i,
         clk_fast                    => clk_i,
         input_fast                  => en_i,
         output_slow                 => en_slow
      );     
   
------------------------------------------------------------------------
--
-- Instantiate spi interface blocks, they all share the same start signal
-- and therefore they are all fired at once.
--
------------------------------------------------------------------------
  -- values tried on DAC Tests with fixed values          
-- comment out full-range to run with rc_test_ssr and generate a square wave
   data (0) <= "1111111111111111";--xffff     full scale
   data (1) <= "1000000000000000";--x8000     half range
   data (2) <= "0000000000000000";--x0000     0
   data (3) <= "0000000000000001";--x0001 
   data (4) <= "0000000000000010";--x0002 
   data (5) <= "0000000000000100";--x0004 
   data (6) <= "0000000000001000";--x0008 
   data (7) <= "0000000000010000";--x0010 

   gen_spi8: for k in 0 to 7 generate
   
      dac_write_spi :write_spi_with_cs
      generic map(DATA_LENGTH => 16)
      port map(--inputs
         spi_clk_i        => clk_4_i,
         rst_i            => rst_i,
         start_i          => send_dac_start,
         parallel_data_i  => dac_data_p(k),
       
         --outputs
         spi_clk_o        => dac_clk_o (k),
         done_o           => dac_done (k),
         spi_ncs_o        => dac_ncs_o (k),
         serial_wr_data_o => dac_dat_o(k)
      );
   end generate gen_spi8;      
 

  -- state register:
   state_FF: process(clk_4_i, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_4_i'event and clk_4_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state, en_fix, en_ramp, ramp_data, ramp)
   begin
      case present_state is
         when IDLE =>     
            if(en_fix = '1') then
               next_state <= PUSH_DATA_FIX;
            elsif(ramp = '1') then
               next_state <= PUSH_DATA_RAMP;
            else
               next_state <= IDLE;
            end if;
                           
         when PUSH_DATA_FIX =>  
            next_state  <= DONE;--SPI_START; -- 2ns settling time for data (ts)
            
         when PUSH_DATA_RAMP =>  
            next_state  <= DONE; --SPI_START; -- 2ns settling time for data (ts)

         when SPI_START =>
            next_state  <= DONE;
         
         when DONE =>
            next_state  <= IDLE;
                        
      end case;
   end process state_NS;
-----------------------------------------------------------------   
   state_out: process(present_state, data,ramp_data,idx, en_fix)
   begin
      for idac in 0 to 7 loop
        dac_data_p(idac) <= (others => '0');
      end loop;            
      done_fix           <= '0';
      fix_data_count_en  <= '0';
      send_dac_start     <= '0';

      case present_state is
         when IDLE =>     
            null;
                  
         when PUSH_DATA_FIX =>    
            for idac in 0 to 7 loop
               dac_data_p(idac) <= data(idx);
            end loop;
            send_dac_start    <= '1';
            fix_data_count_en <= '1';            
                          
         when PUSH_DATA_RAMP =>    
            for idac in 0 to 7 loop
               dac_data_p(idac) <= ramp_data;
            end loop;
            send_dac_start    <= '1';

         when SPI_START =>     -- we may need to hold ramp data in this state        
            for idac in 0 to 7 loop
               dac_data_p(idac) <= data(idx);
            end loop;
            send_dac_start    <= '1';

          when DONE =>        -- we may need to hold ramp data in this state 
            if en_fix = '1' then   
              done_fix        <= '1';
            end if;   
            -- for fix values, we want to assert done_o after one value is loaded
            -- but for the ramp done_o signal is asserted in a process.
       
      end case;
   end process state_out;
-----------------------------------------------------------------   
   process(en_ramp, rst_i, ramp)
   begin
      if (rst_i = '1') then
        ramp <= '0';
      elsif(en_ramp = '1') then
         ramp <= not ramp;
      end if;
   end process;

   process(clk_4_i)
   begin
      if(clk_4_i'event and clk_4_i = '1') then
         done_ramp <= en_ramp;
      end if;
   end process;

   done_o <= done_fix when en_fix = '1' else done_ramp;
   
   end;
 

