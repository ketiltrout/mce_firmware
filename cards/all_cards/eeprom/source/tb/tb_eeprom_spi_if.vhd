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
-- tb_eeprom_spi_if.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Testbench for the eeprom spi read/write interface
--
-- This bench investigates the behaviour of the SPI read/write interface used by
-- the eeprom_ctrl block.  It looks at how many clock cycles are necessary
-- to set up and finish the complete SPI read/write data transfer. 
-- The testbench is self-checking as it has 2 compare loops.
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.eeprom_ctrl_pack.all;


entity tb_eeprom_spi_if is

end tb_eeprom_spi_if;

architecture test of tb_eeprom_spi_if is

   -- testbench constant and signal declarations

   constant CLK_PERIOD      : time                            := 40 ns;   -- 25 MHz system clock period (max.)
   
   shared variable endsim   : boolean                         := false;   -- simulation window


   -- global input signals
   signal   clk             : std_logic                       := '0';     -- 25 MHz system clock
   signal   w_start         : std_logic                       := '0';     -- write trigger      
   signal   r_start         : std_logic                       := '0';     -- read trigger      
   signal   hold_cs         : std_logic                       := '0';     -- whether to hold cs low after operation is done
   signal   wr_pdata        : std_logic_vector(7 downto 0);               -- parallel write data
   signal   rst             : std_logic                       := '0';     -- system reset
   signal   spi_rd_sdat     : std_logic                       := '0';     -- SPI serial data in (read)
   signal   operation       : std_logic                       := '0';     -- indicates read or write operation in progress
   
   
   -- output signals
   signal   spi_csb         : std_logic;                                  -- SPI chip select (active low)
   signal   spi_sclk        : std_logic;                                  -- SPI serial clock
   signal   spi_wr_sdat     : std_logic;                                  -- SPI serial data out (write)

   signal   rd_pdata        : std_logic_vector(7 downto 0);               -- parallel read data
   signal   rd_done         : std_logic;                                  -- end of read operation (output)
   
   -- automated check signals
   signal   sc_data         : std_logic_vector(7 downto 0);              -- serial captured write data
   signal   pc_data         : std_logic_vector(7 downto 0);              -- parallel captured write data

   signal   r_sc_data       : std_logic_vector(7 downto 0);              -- serial captured read data
   signal   r_pc_data       : std_logic_vector(7 downto 0);              -- parallel captured read data

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
   
   wr_parallel_data : process(clk, rst)
   begin
      if rst = '1' then
         wr_pdata <= (others => '0');
      elsif (clk'event and clk = '1') then
         wr_pdata <= wr_pdata + 23;
      end if;
   end process wr_parallel_data;
   
   
   -- Generate the fast input stimulus (a one clk_fast_period pulse)
   -- trigger a write operation and then a read operation
   
   stimulus : process
   begin
      wait until clk ='1';
      w_start <= '1';
      wait for 1.1*CLK_PERIOD;
      w_start <= '0';
      wait for 20*CLK_PERIOD;
      r_start <= '1';
      wait for 1.1*CLK_PERIOD;
      r_start <= '0';
      wait for 20*CLK_PERIOD;
   end process stimulus;

   -- Generate a hold_cs signal
   stimulus2 : process
   begin 
     wait until clk = '1';
     hold_cs <= '1';
     wait for 100*CLK_PERIOD;
     hold_cs <= '0';
     wait for 100*CLK_PERIOD;
   end process stimulus2;
   
   -- indicates whether a read or write operation is in progress
   read_or_write: process (clk, rst)
   begin
      if rst = '1' then
        operation <= '0';
      elsif (clk'event and clk = '1') then
        if (w_start = '1') then
           operation <= '1';
        elsif (r_start = '1') then
           operation <= '0';
        end if;
      end if;  
   end process read_or_write;
   
   -- Generate the serial read data, quite random?!
   rd_sdata : process (clk, rst)
   begin
      if rst = '1' then
         spi_rd_sdat <= '0';
      elsif (clk'event and clk = '1') then
            spi_rd_sdat <= wr_pdata(2); -- just something!
      end if;         
   end process rd_sdata;
      
   -- Capture the write serial data for comparison   
   scapture : process (spi_sclk, rst)
   begin
      if (rst = '1') then
         sc_data <= (others => '0');
      elsif (spi_sclk'event and spi_sclk = '1') then
         if (spi_csb = '0') then
            sc_data(0) <= spi_wr_sdat;
            sc_data(7 downto 1) <= sc_data(6 downto 0);
         end if;
      end if;
   end process scapture;
   
   
   -- Capture the write parallel data input for comparison   
   pcapture : process (clk, rst)
   begin
      if (rst = '1') then
         pc_data <= (others => '0');
      elsif (clk'event and clk = '1') then
         if (w_start = '1') then
            pc_data <= wr_pdata;
         end if;
      end if;
   end process pcapture;
   
   -- Capture the serial read data for comparison   
   read_scapture : process (spi_sclk, rst)
   begin
      if (rst = '1') then
         r_sc_data <= (others => '0');
      elsif (spi_sclk'event and spi_sclk = '1') then
         if (spi_csb = '0') then
            r_sc_data(0) <= spi_rd_sdat;
            r_sc_data(7 downto 1) <= r_sc_data(6 downto 0);
         end if;
      end if;
   end process read_scapture;

   -- Capture the parallel data read output for comparison   
   read_pcapture : process (clk, rst)
   begin
      if (rst = '1') then
         r_pc_data <= (others => '0');
      elsif (clk'event and clk = '1') then
         if (rd_done = '1') then
            r_pc_data <= rd_pdata;
         end if;
      end if;
   end process read_pcapture;
   
   -- Comparisons (Automated check)
   
   compare_wr : process(spi_csb)
   begin
      if (spi_csb'event and spi_csb = '1') then
         if operation = '1' then
            assert (sc_data = pc_data) 
            report "Serial Data Output /= Parallel Data Input (write failure!)"
            severity FAILURE;
         end if;   
      end if;
   end process compare_wr;
   
   compare_rd: process(spi_csb)
   begin 
      if (spi_csb'event and spi_csb = '1') then
         if operation = '0' then
            assert (r_sc_data = r_pc_data) 
            report "Serial Data input /= Parallel Data output (read failure!)"
            severity FAILURE;
         end if;   
      end if;
   end process compare_rd;
   
   
   -- End the simulation after 40000 clock periods
   
   sim_time : process
   begin
      wait for 4000*CLK_PERIOD;
      endsim := true;
      report "Simulation Finished....."
      severity NOTE;
   end process sim_time;
      
   -- Instantiate the Unit Under Test
   
   UUT : eeprom_spi_if
      port map 
         (rst_i          => rst,
          clk_i          => clk,
          spi_wr_start_i => w_start,
          spi_rd_start_i => r_start,
          spi_hold_cs_i  => hold_cs,
          spi_done_o     => rd_done,
          spi_wr_pdat_i  => wr_pdata,
          spi_rd_pdat_o  => rd_pdata,
          spi_csb_o      => spi_csb,
          spi_sclk_o     => spi_sclk,
          spi_sdat_o     => spi_wr_sdat,
          spi_sdat_i     => spi_rd_sdat
          );
      
end test;

   