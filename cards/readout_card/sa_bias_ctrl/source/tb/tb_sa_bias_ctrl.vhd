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
-- tb_sa_bias_ctrl.vhd
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
-- Revision history:
-- 
-- $Log$
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.sa_bias_ctrl_pack.all;


entity tb_sa_bias_ctrl is

end tb_sa_bias_ctrl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.sa_bias_ctrl_pack.all;


architecture test of tb_sa_bias_ctrl is

   -- testbench constant and signal declarations

   constant CLK_SPI_PERIOD  : time                            := 40 ns;   -- 25 MHz SPI clock period (max.)
   constant CLK_SYS_PERIOD  : time                            := 20 ns;   -- 50 MHz system clock period
   
   shared variable endsim   : boolean                         := false;   -- simulation window


   -- global input signals
   signal   clk_spi         : std_logic                       := '0';     -- 25 MHz SPI clock
   signal   clk_sys         : std_logic                       := '0';     -- 50 MHz system clock
   signal   start           : std_logic                       := '0';     -- write trigger      
   signal   pdata           : std_logic_vector(15 downto 0)   := (others => '0');     -- parallel data
   signal   sa_bias_dat     : std_logic_vector(WB_DATA_WIDTH-1 downto 0); -- sa bias data wishbone input 
   signal   rst             : std_logic                       := '0';     -- system reset
   
   -- output bus signals
   -- SPI chip select (active low) Bit 2
   -- SPI serial clock Bit 1
   -- SPI serial data Bit 0
   signal   sa_bias_spi_bus : std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
   
   -- automated check signals
   signal   sc_data         : std_logic_vector(15 downto 0);              -- serial captured data
   signal   pc_data         : std_logic_vector(15 downto 0);              -- parallel captured data
   
   
   
   -- UUT component declaration 
   component sa_bias_ctrl is
      port ( 
         rst_i                     : in     std_logic;                                     -- global reset
         clk_25_i                  : in     std_logic;                                     -- global clock (25 MHz)
         clk_50_i                  : in     std_logic;                                     -- global clock (50 MHz)    
         restart_frame_aligned_i   : in     std_logic;                                     -- start of frame signal (50 MHz domain)
         sa_bias_dat_i             : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);    -- parallel sa bias data input value from wishbone feedback data
         sa_bias_dac_spi_o         : out    std_logic_vector(SPI_DATA_WIDTH-1 downto 0)    -- serial sa bias data output value, clock and chip select
      );
   end component sa_bias_ctrl;
   

begin


   -- Bring out of reset after 20 system clock periods
    
   rst <= '1', '0' after 20*CLK_SYS_PERIOD;


   -- Generate both the system and SPI clocks (ie 20 ns and 40 ns period)
  
   clk_sys_gen : process
   begin
      if not (endsim) then
         clk_sys <= not clk_sys;
         wait for CLK_SYS_PERIOD/2;
      end if;
   end process clk_sys_gen;
     
   clk_spi_gen : process
   begin
      if not (endsim) then
         clk_spi <= not clk_spi;
         wait for CLK_SPI_PERIOD/2;
      end if;
   end process clk_spi_gen;
  
  
   -- Zero-padded parallel_data to 32 bits
   
   sa_bias_dat <= x"0000" & pdata;
   
   
   -- Generate the system start input stimulus for SPI write transfter 
   -- (a one CLK_SYS_PERIOD pulse)
   
   stimulus : process
   begin
      wait until clk_sys ='1';
      start <= '1';
      wait for 1.1*CLK_SYS_PERIOD;
      start <= '0';
      -- Increment the parallel data at about midway of each write transfer
      -- This allows the sampling of parallel data for comparison with serial
      -- data by not allowing any changes close to the active start pulse.
      wait for 20*CLK_SYS_PERIOD;
      pdata <= pdata + 1;
      wait for 20*CLK_SYS_PERIOD;
   end process stimulus;
   
   
   -- Capture the serial data for comparison
      
   scapture : process (sa_bias_spi_bus, rst)
   begin
      if (rst = '1') then
         sc_data <= (others => '0');
      elsif (sa_bias_spi_bus(1)'event and sa_bias_spi_bus(1) = '1') then
         if (sa_bias_spi_bus(2) = '0') then
            sc_data(0) <= sa_bias_spi_bus(0);
            sc_data(15 downto 1) <= sc_data(14 downto 0);
         end if;
      end if;
   end process scapture;
      
      
   -- Capture the parallel data input for comparison
     
   pcapture : process (clk_sys, rst)
   begin
      if (rst = '1') then
         pc_data <= (others => '0');
      elsif (clk_sys'event and clk_sys = '1') then
         if (start = '1') then
            pc_data <= pdata;
         end if;
      end if;
   end process pcapture;
      
      
   -- Comparison (Automated check)
      
   compare : process(sa_bias_spi_bus)
   begin
      if (sa_bias_spi_bus(2)'event and sa_bias_spi_bus(2) = '1') then
         assert (sc_data = pc_data) 
         report "Serial Data Output /= Parallel Data Input"
         severity FAILURE;
      end if;
   end process compare;
      
   
   -- End the simulation after 200 system clock periods
   
   sim_time : process
   begin
      wait for 40000*CLK_SYS_PERIOD;
      endsim := true;
      report "Simulation Finished....."
      severity NOTE;
   end process sim_time;
   
      
   -- Instantiate the Unit Under Test
   
   UUT : sa_bias_ctrl
      port map 
         (rst_i                   => rst,
          clk_25_i                => clk_spi,
          clk_50_i                => clk_sys,
          restart_frame_aligned_i => start,
          sa_bias_dat_i           => sa_bias_dat,
          sa_bias_dac_spi_o       => sa_bias_spi_bus
          );
   
   
end test;

   