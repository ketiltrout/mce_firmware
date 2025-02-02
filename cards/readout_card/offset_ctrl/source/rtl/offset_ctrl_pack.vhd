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
-- offset_ctrl_pack.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Offset control firmware package
--
-- Contains definitions of components and constants specific to offset_ctrl block
--
--
-- Revision history:
-- 
-- $Log: offset_ctrl_pack.vhd,v $
-- Revision 1.3  2004/11/26 18:27:17  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/11/16 18:34:19  anthonyk
-- Changed SPI_DATA_WIDTH to OFFSET_SPI_DATA_WIDTH
--
-- Revision 1.1  2004/11/10 23:28:14  anthonyk
-- Initial release
--
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.flux_loop_ctrl_pack.all;

package offset_ctrl_pack is


   ---------------------------------------------------------------------------------
   -- Offset control constants
   ---------------------------------------------------------------------------------
   

   constant FAST_TO_SLOW_RATIO       : integer := 4;         -- fast to slow clock ratio
   
     
   ---------------------------------------------------------------------------------
   -- SPI write interface component
   ---------------------------------------------------------------------------------
      
   component offset_spi_if is
      port (
         rst_i                       : in      std_logic;    
         clk_i                       : in      std_logic;  
         spi_start_i                 : in      std_logic;
         spi_pdat_i                  : in      std_logic_vector(OFFSET_DATA_WIDTH-1 downto 0);
         spi_csb_o                   : out     std_logic;
         spi_sclk_o                  : out     std_logic;
         spi_sdat_o                  : out     std_logic         
      );
   end component offset_spi_if;
      
      
   ---------------------------------------------------------------------------------
   -- Clock domain crossing component
   ---------------------------------------------------------------------------------   
   
   component offset_clk_domain_crosser is
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
   end component offset_clk_domain_crosser;
   
   
end offset_ctrl_pack;
