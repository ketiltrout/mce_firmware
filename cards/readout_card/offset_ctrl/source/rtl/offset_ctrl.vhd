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
-- offset_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Offset control firmware
--
-- Upon each restart_frame_aligned input, this block converts a parallel 32-bit
-- (with 31:16 bits ignored) offset value obtained from the wishbone feedback 
-- data interface to serial format.  It then sends down the offset value over 
-- the 3-bit SPI interface to the DAC (MAX 5443).
--
--
-- Instantiates: 
-- 1. offset_clk_domain_crosser
-- 2. offset_spi_if
--
--
-- Revision history:
-- 
-- $Log: offset_ctrl.vhd,v $
-- Revision 1.2  2004/11/16 18:18:13  anthonyk
-- Corrected comments
--
-- Revision 1.1  2004/11/13 01:23:13  anthonyk
-- Initial release
--
--
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.offset_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity offset_ctrl is
   port ( 
   
      -- global signals
      rst_i                     : in     std_logic;                                             -- global reset
      clk_25_i                  : in     std_logic;                                             -- global clock (25 MHz)
      clk_50_i                  : in     std_logic;                                             -- global clock (50 MHz)
           
      -- control signals from frame timing block
      restart_frame_aligned_i   : in     std_logic;                                             -- start of frame signal (50 MHz domain)
      
      -- control signals from configuration register
      offset_dat_i              : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- parallel offset data input value from wishbone feedback data
      
      -- SPI interface to MAX 5443 DAC
      offset_dac_spi_o          : out    std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0)     -- serial offset data output value, clock and chip select
          
   );
end offset_ctrl;


library ieee;
use ieee.std_logic_1164.all;
   
library work;
use work.offset_ctrl_pack.all;
   
library sys_param;
use sys_param.wishbone_pack.all;
   
   
architecture struct of offset_ctrl is
   
     -- internal signal declarations
   
      signal spi_write_start           : std_logic;             -- trigger signal to start writing data over the spi interface
      signal spi_csb                   : std_logic;
      signal spi_sclk                  : std_logic;
      signal spi_sdat                  : std_logic;
   
begin
   -- Clock domain crossing component
   -- this block brings the restart_frame_aligned input from the fast clock domain (50 MHz)
   -- to the slow clock domain (25 MHz).  It assumes no phase relationship between
   -- the two clocks.
      
   i_offset_clk_domain_crosser : offset_clk_domain_crosser
     generic map (
         NUM_TIMES_FASTER            => FAST_TO_SLOW_RATIO
      )
            
      port map (
         rst_i                       => rst_i,
         clk_slow                    => clk_25_i,
         clk_fast                    => clk_50_i,
         input_fast                  => restart_frame_aligned_i,
         output_slow                 => spi_write_start
      );     
      
      
   ----------------------
   -- 25 MHz clock domain
   ----------------------
      
   -- SPI write interface component
   -- this block performs the parallel to serial data conversion and sends the serial bit stream in SPI format
   -- to the MAX 5543 DAC
      
   i_offset_spi_if : offset_spi_if
      port map (
         rst_i                       => rst_i,
         clk_i                       => clk_25_i,
         spi_start_i                 => spi_write_start,
         spi_pdat_i                  => offset_dat_i(OFFSET_DATA_WIDTH-1 downto 0),
         spi_csb_o                   => spi_csb,
         spi_sclk_o                  => spi_sclk,
         spi_sdat_o                  => spi_sdat
      );
         
      
   -- Combine the three SPI-related signals into the top-level output bus
   -- Bit 2:  chip select (active low)
   -- Bit 1:  serial clock out
   -- Bit 0:  serial data out
      
   offset_dac_spi_o <= spi_csb & spi_sclk & spi_sdat;
      
      
end struct;

