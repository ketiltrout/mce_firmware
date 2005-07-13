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
-- eeprom_ctrl_pack.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- eeprom control firmware package
--
-- Contains definitions of components and constants specific to eeprom_ctrl block
--
--
-- Revision history:
-- <date $Date: 2005/06/15 21:26:34 $>    - <initials $Author: mandana $>
-- $Log: eeprom_ctrl_pack.vhd,v $
-- Revision 1.1  2005/06/15 21:26:34  mandana
-- *** empty log message ***
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;

-- System Library
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package eeprom_ctrl_pack is
   

   ---------------------------------------------------------------------------------
   -- eeprom control constants
   ---------------------------------------------------------------------------------
   

   constant FAST_TO_SLOW_RATIO       : integer := 2;         -- fast to slow clock ratio
   constant SLOW_TO_FAST_RATIO       : integer := 2;         -- slow to fast clock ratio
   

   ---------------------------------------------------------------------------------
   -- eeprom AT25128A Instruction constants
   ---------------------------------------------------------------------------------
   constant WREN_CMD                 : std_logic_vector(7 downto 0) := x"06";
   constant WRDI_CMD                 : std_logic_vector(7 downto 0) := x"04";
   constant RDSR_CMD                 : std_logic_vector(7 downto 0) := x"05";
   constant WRSR_CMD                 : std_logic_vector(7 downto 0) := x"01";
   constant READ_CMD                 : std_logic_vector(7 downto 0) := x"03";
   constant WRITE_CMD                : std_logic_vector(7 downto 0) := x"02";
   
   constant EEPROM_ADDR_FILLER       : std_logic_vector (1 downto 0) := "00";   -- to fill the 16 bits
   constant EEPROM_ADDR_WIDTH        : integer := 14;
   constant EEPROM_DATA_WIDTH        : integer := 8;
   constant EE_MAX_BIT_TAG           : integer := 6; -- to address 64 bytes of data (i.e. page-mode size for at25128)
   constant EE_PAGE_SIZE             : integer := 64;
   
   ---------------------------------------------------------------------------------
   -- eeprom wishbone block
   ---------------------------------------------------------------------------------
      
   component eeprom_wbs is    
      port (
   
         -- Global signals
         rst_i                   : in std_logic;
         clk_50_i                : in std_logic;
  
         -- signals to/from eeprom_ctrl
         read_req_o              : out std_logic;                                       -- trigger a read from eeprom
         write_req_o             : out std_logic;                                       -- trigger a write to eeprom    
         hold_cs_o               : out std_logic;                                       -- indicates whether eeprom_ctrl should hold the cs low for more reads and writes
         ee_dat_o                : out std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);  -- data to be written in eeprom
         ee_dat_stb_o            : out std_logic;                                       -- strobe for data written to eeprom
         
         start_addr_o            : out std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);  -- start_address for read or write  

         ee_busy_i               : in std_logic;                                        -- indicates eeprom busy
         
         ee_dat_i                : in std_logic_vector (EEPROM_DATA_WIDTH-1 downto 0);  -- data read from eeprom
         ee_dat_stb_i            : in std_logic;                                        -- strobe for data read from eeprom
         
         -- signals to/from dispatch  (wishbone interface)
         dat_i                   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
         addr_i                  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
         tga_i                   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- 
         we_i                    : in std_logic;                                        -- write//read enable
         stb_i                   : in std_logic;                                        -- strobe 
         cyc_i                   : in std_logic;                                        -- cycle
         dat_o 	                 : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);      -- data out
         ack_o                   : out std_logic                                        -- acknowledge out
      ); 
   end component eeprom_wbs;

   ---------------------------------------------------------------------------------
   -- eeprom admin block
   ---------------------------------------------------------------------------------
   
   component eeprom_admin is
      port (    

         -- global signals
         rst_i                     : in     std_logic;                                    -- global reset
         clk_25_i                  : in     std_logic;                                    -- global clock (25 MHz)
         clk_50_i                  : in     std_logic;                                    -- global clock (50 MHz)
              									    
         -- control signals from eeprom_wbs block
         read_req_i                : in     std_logic;                                    -- trigger a read from eeprom
         write_req_i               : in     std_logic;                                    -- trigger a write to eeprom    
         hold_cs_i                 : in     std_logic;                                    -- indicates whether eeprom_ctrl should hold the cs low for more reads and writes
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
   end component eeprom_admin;
   
   ---------------------------------------------------------------------------------
   -- eeprom read control block
   ---------------------------------------------------------------------------------
   
   component eeprom_rd_ctrl is
      port ( 
      
         -- global signals
         rst_i                     : in     std_logic;                                    -- global reset
         clk_50_i                  : in     std_logic;                                    -- global clock (50 MHz)
              									    
         -- control signals from eeprom_wbs block
         read_req_i                : in     std_logic;                                    -- trigger a read from eeprom      
         start_addr_i              : in     std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);-- start_address for read or write  
         
         -- interface to spi block
         dat_o                     : out    std_logic_vector (EEPROM_DATA_WIDTH-1 downto 0);
         spi_wr_start_o            : out    std_logic;
         spi_rd_start_o            : out    std_logic;
         spi_done_i                : in     std_logic;

         
         -- interface to eeprom_ctrl block
         hold_cs_i                 : in     std_logic;
         ee_dat_stb_o              : out    std_logic                                     -- strobe for data read from eeprom
      );
   end component eeprom_rd_ctrl;
   
   ---------------------------------------------------------------------------------
   -- SPI write interface component
   ---------------------------------------------------------------------------------
      
   component eeprom_spi_if is
      port (
         rst_i                       : in      std_logic;    
         clk_i                       : in      std_logic;  
         spi_wr_start_i              : in      std_logic;
         spi_rd_start_i              : in      std_logic;
         spi_hold_cs_i               : in      std_logic;
         spi_done_o                  : out     std_logic;                    
         spi_wr_pdat_i               : in      std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
         spi_rd_pdat_o               : out     std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
         spi_csb_o                   : out     std_logic;
         spi_sclk_o                  : out     std_logic;
         spi_sdat_o                  : out     std_logic;
         spi_sdat_i                  : in      std_logic
      );
   end component eeprom_spi_if;               
   
end eeprom_ctrl_pack;
