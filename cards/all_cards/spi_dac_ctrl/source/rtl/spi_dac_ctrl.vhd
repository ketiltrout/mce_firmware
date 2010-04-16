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
-- spi_dac_ctrl.vhd
--
-- Project:   SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- SPI DAC control firmware (MAX5443)
--
-- Upon each restart_frame_aligned input, this block serializes a parallel 32-bit
-- (with 31:16 bits ignored) bias value obtained from the wishbone  interface
-- and then sends it over the 3-bit SPI interface to the DAC (MAX 5443).
--
-- Instantiates: 
-- 1. clk_domain_crosser
-- 2. spi_if
--
--
-- Revision history:
-- 
-- $Log: spi_dac_ctrl.vhd,v $
-- Revision 1.1.2.1  2009/12/09 00:31:54  mandana
-- added spi_dac_ctrl for controlling SPI DACs
--
--
--
--
--

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

library work;
use work.all_cards_pack.all;

entity spi_dac_ctrl is
   generic (
      DAC_DATA_WIDTH : integer range 1 to 32 := 16;
      CLK_RATIO : integer range 1 to 8 := 2                                            -- divided ratio of fast (MAIN) clock to slow (SPI) clock
      );
   port (  
      -- global signals
      rst_i                     : in     std_logic;                                     -- global reset
      clk_25_i                  : in     std_logic;                                     -- global clock (25 MHz)
      clk_50_i                  : in     std_logic;                                     -- global clock (50 MHz)
           
      -- control signals from frame timing block
      restart_frame_aligned_i   : in     std_logic;                                     -- start of frame signal (50 MHz domain)
      
      -- control signal indicates dat_i is updated
      dat_rdy_i                 : in     std_logic;
      
      -- parallel data to be serialized
      dat_i                     : in     std_logic_vector(DAC_DATA_WIDTH-1 downto 0);    -- parallel data input value from wishbone 
      
      -- SPI interface to MAX 5443 DAC
      dac_spi_o                 : out    std_logic_vector(SPI_DATA_WIDTH-1 downto 0) 	-- serial (SPI) data output value, clock and chip select
   );   
end spi_dac_ctrl;
   
architecture struct of spi_dac_ctrl is

  -- internal signal declarations

   signal spi_write_start           : std_logic;             -- trigger signal to start writing data over the spi interface
   signal spi_csb                   : std_logic;
   signal spi_sclk                  : std_logic;
   signal spi_sdat                  : std_logic;
   signal update_frame_aligned      : std_logic;
   signal update_pending            : std_logic;

begin
   update_frame_aligned <= restart_frame_aligned_i and update_pending;
   
   extend_update:process(rst_i, clk_50_i)
   begin
     if (rst_i = '1') then
       update_pending <='0';
     elsif (clk_50_i'event and clk_50_i = '1') then
       if (dat_rdy_i = '1') then
         update_pending <= '1';
       elsif (restart_frame_aligned_i = '1') then
         update_pending <= '0';
       else   
         update_pending <= update_pending;
       end if;       
     end if;  
   end process; -- extend_update;
   
   -- Clock domain crossing component
   -- this block brings the restart_frame_aligned input from the fast clock domain (50 MHz)
   -- to the slow clock domain (25 MHz).  It assumes no phase relationship between
   -- the two clocks.
   
   i_clk_domain_crosser : fast2slow_clk_domain_crosser
      generic map (
         NUM_TIMES_FASTER            => CLK_RATIO
      )
         
      port map (
         rst_i                       => rst_i,
         clk_slow                    => clk_25_i,
         clk_fast                    => clk_50_i,
         input_fast                  => update_frame_aligned,
         output_slow                 => spi_write_start
      );     
   
   ----------------------
   -- 25 MHz clock domain
   ----------------------
   -- SPI write interface component
   -- this block performs the parallel to serial data conversion and sends the serial bit stream in SPI format
   -- to the MAX 5543 DAC
   
   i_spi_if : spi_if
      generic map (
         PDATA_WIDTH                 => DAC_DATA_WIDTH
      )   
      port map (
         rst_i                       => rst_i,
         clk_i                       => clk_25_i,
         spi_start_i                 => spi_write_start,
         spi_pdat_i                  => dat_i(DAC_DATA_WIDTH-1 downto 0),
         spi_csb_o                   => spi_csb,
         spi_sclk_o                  => spi_sclk,
         spi_sdat_o                  => spi_sdat
      );
      
   
   -- Combine the three SPI-related signals into the top-level output bus
   -- Bit 2:  chip select (active low)
   -- Bit 1:  serial clock out
   -- Bit 0:  serial data out
   
   dac_spi_o <= spi_csb & spi_sclk & spi_sdat;
   
   
end struct;

