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
-- tb_sa_bias_spi_if.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Testbench for the sa bias spi write interface
--
-- This bench investigates the behaviour of the SPI write interface used by
-- the sa_bias_ctrl block.  It looks at how many clock cycles are necessary
-- to set up and finish the complete SPI write data transfer.
--
--
-- Revision history:
-- 
-- $Log$
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.sa_bias_ctrl_pack.all;


entity tb_sa_bias_spi_if is

end tb_sa_bias_spi_if;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.sa_bias_ctrl_pack.all;


architecture test of tb_sa_bias_spi_if is

   -- testbench constant and signal declarations

   constant CLK_PERIOD      : time                            := 40 ns;   -- 25 MHz system clock period (max.)
   
   shared variable endsim   : boolean                         := false;   -- simulation window


   -- global input signals
   signal   clk             : std_logic                       := '0';     -- 25 MHz system clock
   signal   start           : std_logic                       := '0';     -- write trigger      
   signal   pdata           : std_logic_vector(15 downto 0);              -- parallel data
   signal   rst             : std_logic                       := '0';     -- system reset
   
   -- output signals
   signal   spi_csb         : std_logic;                                  -- SPI chip select (active low)
   signal   spi_sclk        : std_logic;                                  -- SPI serial clock
   signal   spi_sdat        : std_logic;                                  -- SPI serial data
   
   -- automated check signals
   signal   sc_data         : std_logic_vector(15 downto 0);              -- serial captured data
   signal   pc_data         : std_logic_vector(15 downto 0);              -- parallel captured data
   

begin


   -- Bring out of reset after 10 clock periods
   
   rst <= '1', '0' after 10*CLK_PERIOD;

  
   -- Generate the system clock (40 ns period)

   clk_gen : process
   begin
      if not (endsim) then
         clk <= not clk;
         wait for CLK_PERIOD/2;
      end if;
   end process clk_gen;
   
   
   -- Generate the parallel data input, essentially incrementing counter
   
   parallel_data : process(clk, rst)
   begin
      if rst = '1' then
         pdata <= (others => '0');
      elsif (clk'event and clk = '1') then
         pdata <= pdata + 1;
      end if;
   end process parallel_data;
   
   
   -- Generate the fast input stimulus (a one clk_fast_period pulse)
   
   stimulus : process
   begin
      wait until clk ='1';
      start <= '1';
      wait for 1.1*CLK_PERIOD;
      start <= '0';
      wait for 20*CLK_PERIOD;
   end process stimulus;
   
   
   -- Capture the serial data for comparison
   
   scapture : process (spi_sclk, rst)
   begin
      if (rst = '1') then
         sc_data <= (others => '0');
      elsif (spi_sclk'event and spi_sclk = '1') then
         if (spi_csb = '0') then
            sc_data(0) <= spi_sdat;
            sc_data(15 downto 1) <= sc_data(14 downto 0);
         end if;
      end if;
   end process scapture;
   
   
   -- Capture the parallel data input for comparison
   
   pcapture : process (clk, rst)
   begin
      if (rst = '1') then
         pc_data <= (others => '0');
      elsif (clk'event and clk = '1') then
         if (start = '1') then
            pc_data <= pdata;
         end if;
      end if;
   end process pcapture;
   
   
   -- Comparison (Automated check)
   
   compare : process(spi_csb)
   begin
      if (spi_csb'event and spi_csb = '1') then
         assert (sc_data = pc_data) 
         report "Serial Data Output /= Parallel Data Input"
         severity FAILURE;
      end if;
   end process compare;
   
     
   -- End the simulation after 40000 clock periods
   
   sim_time : process
   begin
      wait for 40000*CLK_PERIOD;
      endsim := true;
      report "Simulation Finished....."
      severity NOTE;
   end process sim_time;
   
      
   -- Instantiate the Unit Under Test
   
   UUT : sa_bias_spi_if
      port map 
         (rst_i       => rst,
          clk_i       => clk,
          spi_start_i => start,
          spi_pdat_i  => pdata,
          spi_csb_o   => spi_csb,
          spi_sclk_o  => spi_sclk,
          spi_sdat_o  => spi_sdat
          );
   
   
end test;

   