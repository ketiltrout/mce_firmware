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
-- <revision control keyword substitutions e.g. $Id: bc_dac_ctrl_test.vhd,v 1.7 2004/06/22 18:39:02 bench2 Exp $>

--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- bc_dac_ctrl_test file: It sends fixed values to the inputs of the
-- all the DACs at once.
--
-- Revision history:
-- <date $Date: 2004/06/22 18:39:02 $>	- <initials $Author: bench2 $>
-- $Log: bc_dac_ctrl_test.vhd,v $
-- Revision 1.7  2004/06/22 18:39:02  bench2
-- added more fixed values up to 0x0040
--
-- Revision 1.6  2004/06/22 17:21:53  mandana
-- added more fixed values
--
-- Revision 1.5  2004/06/08 19:04:02  mandana
-- clean up (from test signals)
--
-- Revision 1.4  2004/06/07 23:18:48  bench2
-- Mandana: lvds added
--
-- Revision 1.3  2004/06/04 21:00:26  bench2
-- Mandana: ramp test works now
--
-- Revision 1.2  2004/05/29 19:12:55  erniel
-- synthesized,  fixed value test debugged
--
-- Revision 1.1  2004/05/22 00:50:15  erniel
-- Initial release, not compiled
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
use work.dac_ctrl_pack.all;

-----------------------------------------------------------------------------
                     
entity bc_dac_ctrl_test_wrapper is
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
      
      spi_start_o     : out std_logic;
      lvds_spi_start_o: out std_logic      
   );   
end;  

---------------------------------------------------------------------

architecture rtl of bc_dac_ctrl_test_wrapper is

-- DAC CTRL:
-- State encoding and state variables:

-- controller states:
type states is (IDLE, PUSH_DATA, SPI_START, DONE); 
signal present_state         : states;
signal next_state            : states;
type   w_array11 is array (10 downto 0) of word16; 
signal data     : w_array11;
signal idac     : integer;
signal ibus     : integer;

signal logic0   : std_logic;
signal logic1   : std_logic;
signal zero     : integer;
signal clk_2    : std_logic;
signal clk_count: integer;
signal val_clk  : std_logic;
signal idx      : integer;
signal send_dac32_start: std_logic;
signal send_dac_LVDS_start: std_logic;
signal dac_done        : std_logic_vector (32 downto 0);


-- parallel data signals for DAC
-- subtype word is std_logic_vector (15 downto 0); 
type   w_array32 is array (32 downto 0) of word16; 
signal dac_data_p      : w_array32;

begin
   logic0 <= '0';
   logic1 <= '1';
   zero <= 0;

   spi_start_o <= send_dac32_start;
   lvds_spi_start_o <= send_dac_LVDS_start;
   
-- instantiate a counter to divide the clock by 2
   clk_div_2: counter
   generic map(MAX => 4)
   port map(clk_i   => clk_i,
            rst_i   => '0',
            ena_i   => '1',
            load_i  => '0',
            down_i  => '0',
            count_i => 0 ,
            count_o => clk_count);
   clk_2   <= '1' when clk_count > 2 else '0';
     
-- instantiate a counter for idx to go through different values    
   idx_count: counter
   generic map(MAX => 9)
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

   gen_spi32: for k in 0 to 31 generate
   
      dac_write_spi :write_spi_with_cs
      generic map(DATA_LENGTH => 16)
      port map(--inputs
         spi_clk_i        => clk_2,
         rst_i            => rst_i,
         start_i          => send_dac32_start,
         parallel_data_i  => dac_data_p(k),
       
         --outputs
         spi_clk_o        => dac_clk_o (k),
         done_o           => dac_done (k),
         spi_ncs_o        => dac_ncs_o (k),
         serial_wr_data_o => dac_dat_o(k)
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
      spi_clk_o        => lvds_dac_clk_o,
      done_o           => dac_done  (32),
      spi_ncs_o        => lvds_dac_ncs_o ,
      serial_wr_data_o => lvds_dac_dat_o
   );
 
  -- values tried on DAC Tests with fixed values                               
   data (0) <= "1111111111111111";--xffff     full scale
   data (1) <= "1000000000000000";--x8000     half range
   data (2) <= "0000000000000000";--x0000     
   data (3) <= "0000000000000001";--x0001 
   data (4) <= "0000000000000010";--x0002 
   data (5) <= "0000000000000100";--x0004 
   data (6) <= "0000000000001000";--x0008 
   data (7) <= "0000000000010000";--x0010 
   data (8) <= "0000000000100000";--x0020
   data (9) <= "0000000001000000";--x0040
  data (10) <= "0000000010000000";--x0080

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
           for idac in 0 to 32 loop
               dac_data_p(idac) <= "0000000000000000";
            end loop;            
            send_dac32_start    <= '0';
            send_dac_lvds_start <= '0';
            val_clk   <= '1';
            done_o    <= '0';
         
         when PUSH_DATA =>    
            for idac in 0 to 32 loop
               dac_data_p(idac) <= data(idx);
            end loop;
            send_dac32_start    <= '0';
            send_dac_lvds_start <= '0';
            val_clk   <= '0';
	    done_o    <= '0';
                          
         when SPI_START =>     
            for idac in 0 to 32 loop
               dac_data_p(idac) <= data(idx);
            end loop;
            send_dac32_start    <= '1';
            send_dac_lvds_start <= '1';
            val_clk   <= '0';
	    done_o    <= '0';

          when DONE =>    
            for idac in 0 to 32 loop
               dac_data_p(idac) <= data(idx);
            end loop;
            send_dac32_start    <= '0';
            send_dac_lvds_start <= '0';
            val_clk   <= '0';
	    done_o    <= '1';
	                              
      end case;
   end process state_out;
 end;
 

