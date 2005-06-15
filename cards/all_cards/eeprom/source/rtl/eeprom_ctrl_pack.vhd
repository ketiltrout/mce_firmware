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
-- <date $Date$>    - <initials $Author$>
-- $Log$
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package eeprom_ctrl_pack is


   ---------------------------------------------------------------------------------
   -- eeprom control constants
   ---------------------------------------------------------------------------------
   

   constant FAST_TO_SLOW_RATIO       : integer := 4;         -- fast to slow clock ratio
   

   ---------------------------------------------------------------------------------
   -- eeprom AT25128A Instruction constants
   ---------------------------------------------------------------------------------
   constant WREN                     : std_logic_vector(7 downto 0) := x"06";
   constant WRDI                     : std_logic_vector(7 downto 0) := x"04";
   constant RDSR                     : std_logic_vector(7 downto 0) := x"05";
   constant WRSR                     : std_logic_vector(7 downto 0) := x"01";
   constant READ                     : std_logic_vector(7 downto 0) := x"03";
   constant WRITE                    : std_logic_vector(7 downto 0) := x"02";
   
   constant EEPROM_ADDR_WIDTH        : integer := 14;
   constant EEPROM_DATA_WIDTH        : integer := 8;
   constant EE_MAX_BIT_TAG           : integer := 4; -- to address 64 bytes of data or 16 32-bit words(i.e. page-mode size for at25128)
   constant EE_PAGE_SIZE             : integer := 64;
   
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
         spi_wr_pdat_i               : in      std_logic_vector(7 downto 0);
         spi_rd_pdat_o               : out     std_logic_vector(7 downto 0);
         spi_csb_o                   : out     std_logic;
         spi_sclk_o                  : out     std_logic;
         spi_sdat_o                  : out     std_logic;
         spi_sdat_i                  : in      std_logic
      );
   end component eeprom_spi_if;
      
      
   ---------------------------------------------------------------------------------
   -- Clock domain crossing component
   ---------------------------------------------------------------------------------   
   
   component eeprom_clk_domain_crosser is
      generic (
         NUM_TIMES_FASTER            : integer := 2
      );
         
      port (
         rst_i                       : in      std_logic;
	 clk_slow                    : in      std_logic;
	 clk_fast                    : in      std_logic;
	 input_fast                  : in      std_logic;
	 output_slow                 : out     std_logic
      );  
   end component eeprom_clk_domain_crosser;
   
   
end eeprom_ctrl_pack;
