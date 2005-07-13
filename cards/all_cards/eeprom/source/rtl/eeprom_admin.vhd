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
-- eeprom_admin.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- eeprom control block
--
-- This block handles read and write operations for AT25128, a 16k x 8b eeprom.
-- During a write operation, it receives 32-bit(upper 24 bits ignored) data 
-- from wishbone along with a starting address and writes the data to the eeprom
-- through the spi interface. Data is written in 64-byte chunks. The cs pin is 
-- controlled solely by this block during the write operation.
-- During the read operation, it starts reading from the start_address until 
-- read_request is deasserted.
--
--
-- Instantiates: 
-- 1. fast2slow_clk_domain_crosser
-- 2. eeprom_spi_if
-- 3. eeprom_rd_ctrl
--
--
-- Revision history:
-- 
-- <date $Date$>    - <initials $Author$>
-- $Log$
--
--
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.eeprom_ctrl_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity eeprom_admin is
   port ( 
   
      -- global signals
      rst_i                     : in     std_logic;                                    -- global reset
      clk_25_i                  : in     std_logic;                                    -- global clock (25 MHz)
      clk_50_i                  : in     std_logic;                                    -- global clock (50 MHz)
           									    
      -- control signals to/from eeprom_wbs block
      read_req_i                : in     std_logic;                                    -- trigger a read from eeprom
      write_req_i               : in     std_logic;                                    -- trigger a write to eeprom    
      hold_cs_i                 : in     std_logic;                                    -- indicates whether eeprom_admin should hold the cs low for more reads and writes
      ee_dat_i                  : in     std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);-- data to be written to eeprom
      ee_dat_stb_i              : in     std_logic;                                    -- strobe for data written to eeprom
      
      start_addr_i              : in     std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);-- start_address for read or write  

      ee_busy_o                 : out    std_logic;                                    -- eeprom busy 
      
      ee_dat_o                  : out    std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);-- data read from eeprom
      ee_dat_stb_o              : out    std_logic;                                     -- strobe for data read from eeprom
      
      -- SPI interface to AT25128 EEPROM
      eeprom_spi_o              : out    std_logic_vector(2 downto 0);                  -- serial eeprom data, clock and chip select outputs
      eeprom_spi_i              : in     std_logic                                      -- serial eeprom input data
   );
end eeprom_admin;

architecture rtl of eeprom_admin is
   ---------------------------------------------------------------------------
   -- Registers for one page of data (page size is 64 for AT25128)
   ---------------------------------------------------------------------------
   type ee_data_bank is array (0 to EE_PAGE_SIZE-1) of std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal reg : ee_data_bank;
     
   type wren_banks is array (0 to EE_PAGE_SIZE-1) of std_logic;
   signal wren : wren_banks;

   -- internal signal declarations
 
   signal spi_write_start           : std_logic;             -- trigger signal to start writing data over the spi interface in 50MHz domain
   signal spi_read_start            : std_logic;             -- trigger signal to start reading data over the spi interface   
   signal spi_write_start_slow      : std_logic;             -- spi_write_start in 12.5MHz domain
   signal spi_read_start_slow       : std_logic;             -- spi_read_start in 12.5MHz domain    
   signal read_cmd_start            : std_logic;             -- trigger signal to start writing read_cmd to spi interface
   signal write_cmd_start           : std_logic;             -- trigger signal to start writing write_cmd to spi interface
   signal spi_csb                   : std_logic;
   signal spi_sclk                  : std_logic;
   signal spi_so                    : std_logic;
   signal spi_si                    : std_logic;
   
   signal ix                        : std_logic_vector(EE_MAX_BIT_TAG downto 0);
   signal spi_rdat                  : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal spi_wdat                  : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal spi_wdat_slow             : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal spi_read_cmd_wdat         : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal spi_write_cmd_wdat        : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal spi_done                  : std_logic;
   signal spi_done_slow             : std_logic;
   
begin

   ---------------------------------------
   -- clcok domain crossing instantiations
   ---------------------------------------
   
   -- fast2slow
   -- the following 2 blocks bring the spi_write_start and spi_read_start inputs 
   -- from the fast clock domain (50 MHz) to the slow clock domain (25 MHz). It 
   -- assumes no phase relationship between the two clocks.
      
   i_eeprom_clk_domain_crosser1 : fast2slow_clk_domain_crosser
      generic map (
         NUM_TIMES_FASTER            => FAST_TO_SLOW_RATIO
       )
            
      port map (
         rst_i                       => rst_i,
         clk_slow                    => clk_25_i,
         clk_fast                    => clk_50_i,
         input_fast                  => spi_write_start,
         output_slow                 => spi_write_start_slow
      );     

   i_eeprom_clk_domain_crosser2 : fast2slow_clk_domain_crosser
      generic map (
         NUM_TIMES_FASTER            => FAST_TO_SLOW_RATIO
      )
            
      port map (
         rst_i                       => rst_i,
         clk_slow                    => clk_25_i,
         clk_fast                    => clk_50_i,
         input_fast                  => spi_read_start,
         output_slow                 => spi_read_start_slow
      );     
   
   -- data lines crossing clock domains
   i_data_clk_domain_crosser: for i in 0 to EEPROM_DATA_WIDTH-1 generate   
      i_clk_domain_crosser: fast2slow_clk_domain_crosser
         generic map (
            NUM_TIMES_FASTER            => FAST_TO_SLOW_RATIO
         )               
         port map (
            rst_i                       => rst_i,
            clk_slow                    => clk_25_i,
            clk_fast                    => clk_50_i,
            input_fast                  => spi_wdat(i),
            output_slow                 => spi_wdat_slow(i)
         );     
   end generate i_data_clk_domain_crosser;      

   -- slow2fast
   -- this block brings the spi_done input from the slow clock domain
   -- to the fast clock domain
   i_eeprom_clk_domain_crosser_3 : slow2fast_clk_domain_crosser
     generic map ( 
         NUM_TIMES_FASTER            => SLOW_TO_FAST_RATIO
       )
            
      port map (
         rst_i                       => rst_i,
         clk_slow                    => clk_25_i,
         clk_fast                    => clk_50_i,
         input_slow                  => spi_done_slow,
         output_fast                 => spi_done
      );          

  
   ----------------------
   -- 50 MHz clock domain
   ----------------------
   
   -- temporary set the write_cmd_start till wr_ctrl is implemented
   write_cmd_start <= '0';
   spi_write_cmd_wdat <= (others=>'0');
   spi_write_start <=  read_cmd_start or write_cmd_start;
   spi_wdat <= spi_read_cmd_wdat or spi_write_cmd_wdat;
   
   -- eeprom read controller to start the SPI and generate strobe signals for data   
   i_eeprom_rd_ctrl: eeprom_rd_ctrl
      port map (
         rst_i                => rst_i,
         clk_50_i             => clk_50_i,
         read_req_i           => read_req_i,
         start_addr_i         => start_addr_i,
         dat_o                => spi_read_cmd_wdat,
         spi_wr_start_o       => read_cmd_start,
         spi_rd_start_o       => spi_read_start,
         hold_cs_i            => hold_cs_i,
         spi_done_i           => spi_done,
         ee_dat_stb_o         => ee_dat_stb_o      
      );
      
   ----------------------
   -- 25 MHz clock domain
   ----------------------
      
   -- SPI write interface component
   -- this block performs the parallel to serial data conversion and sends the serial bit stream in SPI format
   -- to the EEPROM (AT25128)
      
   i_eeprom_spi_if : eeprom_spi_if
      port map (
         rst_i                => rst_i,
         clk_i                => clk_25_i,
         spi_wr_start_i       => spi_write_start_slow,
         spi_rd_start_i       => spi_read_start_slow,
         spi_hold_cs_i        => hold_cs_i,
         spi_done_o           => spi_done_slow,

         spi_wr_pdat_i        => spi_wdat_slow,
         spi_rd_pdat_o        => spi_rdat,    

         spi_csb_o            => spi_csb,
         spi_sclk_o           => spi_sclk,    
         spi_sdat_o           => spi_so,    
         spi_sdat_i           => spi_si
         
      );
         
      
   -- Combine the three SPI-related signals into the top-level output bus
   -- Bit 2:  chip select (active low)
   -- Bit 1:  serial clock out
   -- Bit 0:  serial data out
      
   eeprom_spi_o <= spi_csb & spi_sclk & spi_so;   
   spi_si <= eeprom_spi_i;
   
   ee_dat_o <= spi_rdat;
   ee_busy_o <= spi_done;
      
end rtl;

