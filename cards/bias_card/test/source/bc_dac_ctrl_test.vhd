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
-- <revision control keyword substitutions e.g. $Id: dac_ctrl_test_wrapper.vhd,v 1.8 2004/05/20 21:54:06 mandana Exp $>

--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- dac_ctrl test wrapper file.  This file instanstiates the dac_ctrl
-- and emulates the master (command FSM, for example) on the wishbone bus.
-- when enabled, same value is loaded to lvds DAC and 32 DACs simultaneously.
-- The next enable signal would load another set of values to the DACs. overall
-- 5 different set of values are loaded.
--
-- Revision history:
-- <date $Date: 2004/05/20 21:54:06 $>	- <initials $Author: mandana $>
-- $Log: dac_ctrl_test_wrapper.vhd,v $
.-----------------------------------------------------------------------------

library ieee, sys_param, components, work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use sys_param.wishbone_pack.all;
use sys_param.frame_timing_pack.all;
use sys_param.data_types_pack.all;
use components.component_pack.all;
use work.dac_ctrl_pack.all;

-----------------------------------------------------------------------------
                     
entity dac_ctrl_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals removed!
                
      -- extended signals
      dac_dat_o : out std_logic_vector (31 downto 0); 
      dac_ncs_o : out std_logic_vector (31 downto 0); 
      dac_clk_o : out std_logic_vector (31 downto 0);
     
      lvds_dac_dat_o: out std_logic;
      lvds_dac_ncs_o: out std_logic;
      lvds_dac_clk_o: out std_logic;
      
      ack_test_o: out std_logic;
      cyc_test_o: out std_logic;
      sync_test_o: out std_logic;
      idac_clk_o: out std_logic
      
   );   
end;  

---------------------------------------------------------------------

architecture rtl of ac_dac_ctrl_test is

-- DAC CTRL:
-- State encoding and state variables:

-- controller states:
type states is (IDLE, PUSH_DATA, CLKNOW, DONE); 
signal present_state         : states;
signal next_state            : states;
type   w_array5 is array (4 downto 0) of word32; 
signal data     : w_array5;
signal idat     : integer;
signal idac     : integer;
signal ibus     : integer;

signal logic0 : std_logic;
signal logic1 : std_logic;
signal zero : integer;
signal clk_8  : std_logic;

begin
   logic0 <= '0';
   logic1 <= '1';
   zero <= 0;

-- instantiate a counter to divide the clock by 8
   clk_div_8: counter
   generic map(MAX => 16)
   port map(clk_i   => clk_i,
            rst_i   => '0',
            ena_i   => '1',
            load_i  => '0',
            down_i  => '0',
            count_i => 0 ,
            count_o => clk_count);

   clk_8   <= '1' when clk_count > 8 else '0'; -- slow down the 50MHz clock to 50/8MHz

-- instantiate a counter for idx to go through different values    
   idx_count: counter
   generic map(MAX => 5)
   port map(clk_i   => val_clk,
            rst_i   => rst_i,
            ena_i   => '1',
            load_i  => '0',
            down_i  => '0',
            count_i =>  0,
            count_o => idx);
 

------------------------------------------------------------------------
--
-- Instantiate spi interface blocks, they all share the same start signal
-- and therefore they are all fired at once.
--
------------------------------------------------------------------------

   gen_spi32: for k in 0 to 31 generate
   
      dac_write_spi :write_spi_with_cs
      generic map(DATA_LENGTH => 16)
      port map(--inputs
         spi_clk_i        => clk_8,
         rst_i            => rst_i,
         start_i          => send_dac32_start,
         parallel_data_i  => dac_data_p(k),
       
         --outputs
         spi_clk_o        => dac_clk_o (k),
         done_o           => dac_done  (k),
         spi_ncs_o        => dac_ncs (k),
         serial_wr_data_o => dac_data_o(k)
      );
   end generate gen_spi32;      
 ----------------------------------------------------------------------
 --
 -- Instantiate the spi for dac_lvds interface seperately
 -- (lvds dac is indexed by 32)
 --
 ----------------------------------------------------------------------
   dac_write_lvds_spi :write_spi_with_cs

   generic map(DATA_LENGTH => 16)

   port map(--inputs
      spi_clk_i        => clk_i,
      rst_i            => rst_i,
      start_i          => send_dac_lvds_start,
      parallel_data_i  => dac_data_p(32),
    
      --outputs
      spi_clk_o        => dac_clk_o (32),
      done_o           => dac_done  (32),
      spi_ncs_o        => dac_ncs (32),
      serial_wr_data_o => dac_data_o(32)
   );
 
-- instantiate a counter for idac to go through all 32 DACs
   data_count: counter
   generic map(MAX => 5)
   port map(clk_i   => en_i,
            rst_i   => rst_i,
            ena_i   => logic1,
            load_i  => logic0,
            down_i  => logic0,
            count_i => zero ,
            count_o => idat);

  -- values tried on DAC Tests with fixed values                               
   data (0) <= "11111111111111111111111111111111";--xffffffff     full scale
   data (1) <= "01010101010101010101010101010101";--x55555555     alternating 0,1
   data (2) <= "00000000000000000000000000000000";--x00000000
   data (3) <= "11110000001100110100000000000101";--xf0334005     asymmetric nibbles
   data (4) <= "11111111111111111111111111111111";--xffffffff -- this entry wouldn't be tried

  -- state register:
   state_FF: process(clk_8, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_8'event and clk_8 = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state, en_i)
   begin
      case present_state is
         when IDLE =>     
            if(en_i = '1') then
               next_state <= PUSH_DATA;
            else
               next_state <= IDLE;
            end if;
                
         when PUSH_DATA =>  
            next_state  <= SPI_START; -- 2ns settling time for data (ts)
            
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
           for idac in 0 to 31 loop
               dac_data_p(idac) <= "00000000000000";
            end loop;            
	    done_o    <= '0';
         
         when PUSH_DATA =>    
            for idac in 0 to 31 loop
               dac_data_p(idac <= data(idx);
            end loop;
	    done_o    <= '0';
                          
         when SPI_START =>     
            send_dac32_start <= '1';
	    done_o    <= '0';

          when DONE =>    
	    done_o    <= '1';
	                              
      end case;
   end process state_out;
   
 end
 

