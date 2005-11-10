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
-- eeprom_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- eeprom block - a wishbone slave
--
-- This block handles read and write operations for AT25128, a 16k x 8b eeprom.
--
-- Instantiates: 
-- 1. eeprom_admin         : eeprom read-write controller
-- 2. eeprom_wbs           : wishbone interface
--
--
-- Revision history:
-- 
-- <date $Date: 2005/07/13 17:47:38 $>    - <initials $Author: mandana $>
-- $Log: eeprom_ctrl.vhd,v $
-- Revision 1.1  2005/07/13 17:47:38  mandana
-- Initial release, write operation not tested yet
--
--
--
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.eeprom_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity eeprom_ctrl is
   port ( 
   
      -- global signals
      rst_i                     : in     std_logic;                                    -- global reset
      clk_25_i                  : in     std_logic;                                    -- global clock (25 MHz)
      clk_50_i                  : in     std_logic;                                    -- global clock (50 MHz)
           									    
      -- signals to/from dispatch  (wishbone interface)
      dat_i                   : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
      addr_i                  : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
      tga_i                   : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- Address Tag
      we_i                    : in  std_logic;                                        -- write//read enable
      stb_i                   : in  std_logic;                                        -- strobe 
      cyc_i                   : in  std_logic;                                        -- cycle
      dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- data out
      ack_o                   : out std_logic;                                        -- acknowledge out
      
      -- SPI interface to AT25128 EEPROM
      eeprom_spi_o              : out    std_logic_vector(2 downto 0);                  -- serial eeprom data, clock and chip select outputs
      eeprom_spi_i              : in     std_logic                                      -- serial eeprom input data
   );
end eeprom_ctrl;
  
architecture rtl of eeprom_ctrl is

   -- internal signal declarations
   
   signal read_req                  : std_logic;
   signal write_req                 : std_logic;
   signal hold_cs                   : std_logic;
   signal w_dat                     : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);    -- parallel data to be written to eeprom
   signal w_dat_stb                 : std_logic;                       -- strobe for data being written to eeprom                            
   signal start_addr                : std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);
   signal ee_busy                   : std_logic;                       -- eeprom busy  

   signal r_dat                     : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);    -- parallel data read from eeprom
   signal r_dat_stb                 : std_logic;                       -- strobe for data read from eeprom                            
   
begin

   i_eeprom_admin : eeprom_admin
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
         ee_dat_o       => r_dat,
         ee_dat_stb_o   => r_dat_stb,
         eeprom_spi_o   => eeprom_spi_o,
         eeprom_spi_i   => eeprom_spi_i
         );		 

   
   i_eeprom_wbs : eeprom_wbs
      port map 
         (rst_i          => rst_i,
          clk_50_i       => clk_50_i,
          read_req_o     => read_req,
          write_req_o    => write_req,
          hold_cs_o      => hold_cs,
          ee_dat_o       => w_dat,
          ee_dat_stb_o   => w_dat_stb,
          start_addr_o   => start_addr,
          ee_busy_i      => ee_busy,
          ee_dat_i       => r_dat,
          ee_dat_stb_i   => r_dat_stb,
          dat_i          => dat_i,
          addr_i	 => addr_i,
          tga_i		 => tga_i,
          we_i		 => we_i,
          stb_i		 => stb_i,
          cyc_i		 => cyc_i,
          dat_o		 => dat_o,
          ack_o		 => ack_o
          );		 
         
end rtl;

