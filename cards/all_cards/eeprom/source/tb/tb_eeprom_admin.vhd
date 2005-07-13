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
-- tb_eeprom_admin.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Testbench for the eeprom admin
-- emulates signals from eeprom_wbs block as welll as eeprom device
-- it is only read operation at this time. 
-- the testbench is self-checking, so watch out for FREE_RUN and 
-- number of clock cycles between emulating eeprom spi_si
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

library sys_param;
use sys_param.wishbone_pack.all;

entity tb_eeprom_admin is

end tb_eeprom_admin;

architecture test of tb_eeprom_admin is

   -- testbench constant and signal declarations

   constant CLK_SYS_PERIOD          : time                            := 20 ns;   -- 50MHz system clock period (max.)
   constant CLK_SPI_PERIOD          : time                            := 40 ns;   -- 25MHz SPI clock period 
   constant EDGE_DEPENDENCY         : time := 2 ns;                       --shows clk edge dependency
   constant RESET_WINDOW            : time := 8*CLK_SYS_PERIOD;
   constant FREE_RUN                : time := 19*CLK_SYS_PERIOD;

   shared variable endsim   : boolean                         := false;   -- simulation window

   -- global input signals
   signal   rst_i           : std_logic                       := '0';     -- system-wide reset
   signal   clk_25_i        : std_logic                       := '0';     -- 25MHz system clock
   signal   clk_50_i        : std_logic                       := '0';     -- 50MHz system clock
      
   -- signals to/from eeprom_wbs block
   signal   read_req        : std_logic                       := '0';     -- triggers a read from eeprom
   signal   write_req       : std_logic                       := '0';     -- triggers a write to eeprom
   signal   hold_cs         : std_logic                       := '0';     -- indicates further bytes to be read or written
   signal   w_dat           : std_logic_vector(7 downto 0)    := x"00";   -- parallel data to be written to eeprom
   signal   w_dat_stb       : std_logic                       := '0';     -- strobe for data being written to eeprom                            
   signal   start_addr      : std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);
   signal   ee_busy         : std_logic                       := '0';     -- eeprom busy  

   signal   r_dat           : std_logic_vector(7 downto 0)    := x"00";   -- parallel data read from eeprom
   signal   r_dat_stb       : std_logic                       := '0';     -- strobe for data read from eeprom           
   signal   pdat            : std_logic_vector(7 downto 0)    := x"00";   
   signal   pdat_single     : std_logic_vector(7 downto 0)    := x"00";
   signal   pdat_multi      : std_logic_vector(7 downto 0)    := x"00";

   -- spi interface to the eeprom device
   signal   spi             : std_logic_vector(2 downto 0)    := "000";   -- spi interface: cs, sclk, so
   signal   spi_cs          : std_logic                       := '1';
   signal   spi_sclk        : std_logic                       := '0';
   signal   spi_so          : std_logic                       := '0';
   signal   spi_si          : std_logic                       := '0';     -- spi input data (serial)
   signal   spi_si_single   : std_logic                       := '0';     -- spi input data (serial)
   signal   spi_si_multi    : std_logic                       := '0';     -- spi input data (serial)
   
   -- check signals to track different tests   
   signal reset_window_done      : boolean                    := false;
   signal finish_single_read     : boolean                    := false;
   signal finish_multi_read      : boolean                    := false;
   signal finish_single_write    : boolean                    := false;
   signal finish_multi_write     : boolean                    := false;
   signal finish_sim             : boolean                    := false;
 
   -- automated check signals
   -- to be defined
   
begin
   -----------------------------------------------------------------------------
   -- generate 50MHz system clock and SPI clock for eeprom
   -----------------------------------------------------------------------------
   clk_sys_gen : process
   begin
      if not (endsim) then
         clk_50_i <= not clk_50_i;
         wait for CLK_SYS_PERIOD/2;
      end if;
   end process clk_sys_gen;
     
   clk_spi_gen : process
   begin
      if not (endsim) then
         clk_25_i <= not clk_25_i;
         wait for CLK_SPI_PERIOD/2;
      end if;
   end process clk_spi_gen;

   -----------------------------------------------------------------------------
   -- read and write from eeprom
   -----------------------------------------------------------------------------
   i_eeprom_read_write: process 
   begin 
      -- setup
      read_req  <= '0';
      write_req <= '0';
      hold_cs     <= '0';
      start_addr  <= (others=>'0');
      w_dat       <= (others=>'0');
      w_dat_stb   <= '0';
      
      wait for RESET_WINDOW;
      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   
      
      -----------------------------------------------
      -- Start a READ 
      read_req     <= '1';
      hold_cs      <= '1';
      start_addr   <= "11010101010101";--0355"'right(14);
      
      -- wait for EDGE_DEPENDENCY;
      -- wait for CLK_SYS_PERIOD;   
      wait until r_dat_stb = '1';
      finish_single_read <= true;
      
      read_req      <= '0';
      hold_cs       <= '0';
--      pdat          <= x"AA";
      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   
   
      -----------------------------------------------
      -- read 7 bytes , make sure to tie this in with how many data you emulate on eeprom_si
      start_addr   <= "11000000000111";--3007"'right(14);

      for i in 0 to 7 loop
         read_req     <= '1';
         hold_cs      <= '1';
         wait until r_dat_stb = '1';         
         read_req <= '0';
         wait for CLK_SYS_PERIOD;
      end loop;  -- i
              
      finish_multi_read <= true;
      read_req     <= '0';
      hold_cs      <= '0';

      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   
      -------------------------------------------------
      -- write 1 byte
      finish_sim <= true;
   end process i_eeprom_read_write;
   
   ------------------------------------------------------------------------------
   -- emulate external interface
   --
   -- data for single read
   emulate_ee_data_single_read: process -- emulate data read from eeprom on the spi_si line
   begin
      wait until reset_window_done;
      wait until read_req = '1';
      wait for 79*CLK_SYS_PERIOD;
      pdat_single <= pdat_single + 23;
      wait for 8*CLK_SYS_PERIOD;
      for i in 0 to 7 loop      
        spi_si_single <= pdat_single(7-i);  
        wait for CLK_SPI_PERIOD;      
      end loop;
      wait until not finish_single_read;
   end process emulate_ee_data_single_read;   
   
   -- data for multiple read
   emulate_ee_data_multi_read: process -- emulate data read from eeprom on the spi_si line
   begin
      wait until finish_single_read;
      wait until read_req = '1';
      wait for 75*CLK_SYS_PERIOD;
      for j in 0 to 7 loop
         pdat_multi <= pdat_multi + 23;
         wait for 12*CLK_SYS_PERIOD;
         for i in 0 to 7 loop      
           spi_si_multi <= pdat_multi(7-i);  
           wait for CLK_SPI_PERIOD;      
         end loop;  
      end loop;
      wait until not finish_multi_read;
   end process emulate_ee_data_multi_read;   
   
   -- mux
   spi_si <= spi_si_multi when finish_single_read else spi_si_single;
   pdat   <= pdat_multi when finish_single_read else pdat_single;
   
   -----------------------------------------------------------------------------
   -- self-checking code to abort if the data injected and data read back are not the same
   --
   compare_rd: process(r_dat_stb)
   begin 
      if (r_dat_stb'event and r_dat_stb = '1') then
         assert (pdat = r_dat) 
         report "Serial Data input spi_si /= Parallel Data output (read failure!)"
         severity FAILURE;
      end if;
   end process compare_rd;
   
   -- Instantiate the Unit Under Test
   -----------------------------------------------------------------------------
   -- Perform Test
   -----------------------------------------------------------------------------
   i_test: process

    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
     
    procedure do_initialize is
    begin
      reset_window_done      <= false;
      rst_i                  <= '1';
                            
      wait for 100 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 100 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;
    
    ------------------------------------------
    begin  -- process i_test
 
       do_initialize;

       wait until finish_single_read;
       wait until finish_multi_read;
--       wait until finish_single_write;
--       wait until finish_multi_write;
       
       -- End of Simulation
--       wait for 1000*CLK_SYS_PERIOD;
       wait until finish_sim;
       endsim := true;
  
       report "Simulation Finished....."
       severity NOTE;
       
    end process i_test;

    
    UUT : eeprom_admin
      port map 
         (rst_i          => rst_i,
          clk_25_i       => clk_25_i,         
          clk_50_i       => clk_50_i,
          read_req_i     => read_req,
          write_req_i    => write_req,
          hold_cs_i      => hold_cs,
          ee_dat_i       => w_dat,
          ee_dat_stb_i   => w_dat_stb,
          start_addr_i   => start_addr,
          ee_busy_o      => ee_busy,
          ee_dat_stb_o   => r_dat_stb,
          ee_dat_o       => r_dat,
          eeprom_spi_o   => spi,
          eeprom_spi_i   => spi_si
          );		 
      			 
end test;

   