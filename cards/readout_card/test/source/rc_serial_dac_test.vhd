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
-- rc_serial_dac_test file: It tests the serial DACs, 
-- if mode = 0, cycles through fixed values on the outputs
-- if mode = 1, then it puts a ramp on the ouputs of the DACs
-- if mode = 2, then it performs the cross-talk test.(in future)
--
--
-- Revision history:
-- <date $Date: 2004/06/22 20:52:45 $>	- <initials $Author: mandana $>
-- $Log: rc_serial_dac_test.vhd,v $
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
use sys_param.frame_timing_pack.all;
use sys_param.data_types_pack.all;
use components.component_pack.all;
-----------------------------------------------------------------------------
                     
entity rc_serial_dac_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
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
type   w_array8 is array (7 downto 0) of word16; 
signal data     : w_array8;

signal idac     : integer;
signal clk_2    : std_logic;
signal clk_count: integer;
signal val_clk  : std_logic;
signal idx      : integer;
signal send_dac_start: std_logic;
signal dac_done : std_logic_vector (7 downto 0);
signal en_fix   : std_logic;
signal en_ramp  : std_logic;
signal ramp     : std_logic;
signal clkcount : std_logic;
signal idata    : integer;

signal logic0   : std_logic;
signal logic1   : std_logic;
signal zero     : integer;
signal ramp_data: std_logic_vector(15 downto 0);
signal done_fix : std_logic;
signal done_ramp: std_logic;

-- parallel data signals for DAC
signal dac_data_p      : w_array8;

begin
   logic0 <= '0';
   logic1 <= '1';
   zero <= 0;

   en_fix  <= en_i when mode = "00" else '0';
   en_ramp <= en_i when mode = "01" else '0';

-- instantiate a counter to divide the clock by 2
   clk_div_2: counter
   generic map(MAX => 4)
   port map(clk_i   => clk_i,
            rst_i   => logic0,
            ena_i   => logic1,
            load_i  => logic0,
            down_i  => logic0,
            count_i => zero ,
            count_o => clk_count);
   clk_2   <= '1' when clk_count > 2 else '0';

-- instantiate a counter for generating ramp
   data_count: counter
   generic map(MAX => 16#ffff#)
   port map(clk_i   => clkcount,
            rst_i   => rst_i,
            ena_i   => ramp,
            load_i  => logic0,
            down_i  => logic0,
            count_i => zero,
            count_o => idata);
  
   clkcount <= dac_done(0);-- when ramp = '1' else '0';
   ramp_data <= conv_std_logic_vector(idata,16);
     
-- instantiate a counter for idx to go through different values    
   idx_count: counter
   generic map(MAX => 6)
   port map(clk_i   => val_clk,
            rst_i   => logic0, -- '0' or rst_i? think!!!!!
            ena_i   => logic1,
            load_i  => logic0,
            down_i  => logic0,
            count_i =>  zero,
            count_o => idx);

------------------------------------------------------------------------
--
-- Instantiate spi interface blocks, they all share the same start signal
-- and therefore they are all fired at once.
--
------------------------------------------------------------------------
  -- values tried on DAC Tests with fixed values                               
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
         spi_clk_i        => clk_2,
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
   state_FF: process(clk_2, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_2'event and clk_2 = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state, en_fix, en_ramp, ramp_data)
   begin
      case present_state is
         when IDLE =>     
            if(en_fix = '1') then
               next_state <= PUSH_DATA_FIX;
            elsif(en_ramp = '1') then
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
   state_out: process(present_state)
   begin
      case present_state is
         when IDLE =>     
           for idac in 0 to 7 loop
               dac_data_p(idac) <= "0000000000000000";
            end loop;            
            send_dac_start    <= '0';
            val_clk           <= '1';
            done_fix          <= '0';
         
         when PUSH_DATA_FIX =>    
            for idac in 0 to 7 loop
               dac_data_p(idac) <= data(idx);
            end loop;
            send_dac_start    <= '1';
            val_clk           <= '0';
	    done_fix          <= '0';
                          
         when PUSH_DATA_RAMP =>    
            for idac in 0 to 7 loop
               dac_data_p(idac) <= ramp_data;
            end loop;
            send_dac_start   <= '1';

         when SPI_START =>     -- we may need to hold ramp data in this state        
                     for idac in 0 to 7 loop
	                dac_data_p(idac) <= data(idx);
	             end loop;

            send_dac_start    <= '1';
            val_clk   <= '0';
	--    done_o    <= '0';

          when DONE =>        -- we may need to hold ramp data in this state 
            send_dac_start    <= '0';
            val_clk   <= '0';
            if en_fix = '1' then   
	       done_fix      <= '1';
	    end if;   
            -- for fix values, we want to assert done_o after one value is loaded
            -- but for the ramp done_o signal is asserted in a process.
	    
      end case;
   end process state_out;
-----------------------------------------------------------------   
   process(en_ramp)
   begin
      if(en_ramp = '1') then
         ramp <= not ramp;
      end if;
   end process;
   
   process(clk_2)
   begin
      if(clk_2'event and clk_2 = '1') then
         done_ramp <= en_ramp;
      end if;
   end process;

   done_o <= done_fix when en_fix = '1' else done_ramp;

   end;
 

