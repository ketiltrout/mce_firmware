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
-- offset_spi_if.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- This is the write interface to the Offset DAC in SPI format.  It 
-- works in the same clock domain as the DAC interface.
-- 
--
--
-- Revision history:
-- 
-- $Log$
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.offset_ctrl_pack.all;


entity offset_spi_if is
   
   port ( 
      
      -- global signals
      rst_i                     : in     std_logic;                                       -- global reset
      clk_i                     : in     std_logic;                                       -- global clock
      
      -- SPI write inputs 
      spi_start_i               : in     std_logic;                                       -- SPI write trigger
      spi_pdat_i                : in     std_logic_vector(OFFSET_DATA_WIDTH-1 downto 0);  -- SPI parallel write data
      
      -- SPI write outputs
      spi_csb_o                 : out    std_logic;                                       -- SPI chip select
      spi_sclk_o                : out    std_logic;                                       -- SPI serial write clock
      spi_sdat_o                : out    std_logic                                        -- SPI serial write data
      
      );
        
end offset_spi_if;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


architecture rtl of offset_spi_if is

   -- internal signal declarations

   signal data_reg      : std_logic_vector(15 downto 0);                                  -- shift data register 
   signal start_delayed : std_logic;                                                      -- delayed version of SPI write trigger
   signal spi_dv        : std_logic;                                                      -- SPI write process in progress 
   signal bit_count     : integer range 0 to spi_pdat_i'length;                           -- sub-bit position counter
  

begin
  
   -- This shift register loads the input data in parallel and outputs it serially.
   -- The register is loaded upon active spi_start_i input.  Otherwise, each bit
   -- takes its input from its next-lower bit with 0 steering into bit 0.
   
   data_reg_proc : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         data_reg <= (others => '0');
      elsif (clk_i'event and clk_i = '1') then
         if (spi_start_i = '1') then
            data_reg <= spi_pdat_i;
         else
            data_reg((spi_pdat_i'length-1) downto 1) <= data_reg((spi_pdat_i'length-2) downto 0);
            data_reg(0) <= '0';
         end if;
      end if;
   end process data_reg_proc;
   
   
   -- The SPI serial data output is sourced from the most significant bit of the 
   -- data shift register.
   
   spi_sdat_proc : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         spi_sdat_o <= '0';
      elsif (clk_i'event and clk_i = '1') then
         spi_sdat_o <= data_reg(spi_pdat_i'length-1);
      end if;
   end process spi_sdat_proc;
   
   
   -- Delay the SPI write trigger pulse by 1 clock period
   
   spi_start_delayer : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         start_delayed <= '0';
      elsif (clk_i'event and clk_i = '1') then
         start_delayed <= spi_start_i;
      end if;
   end process spi_start_delayer;

   
   -- Upon active start_delayed pulse, lower the chip select signal (active low).
   -- Hold it at low-level until SPI write data valid window is deasserted.
   -- The window is active for the whole duration of shifting out the parallel data
   -- bits over the DAC SPI interface.
   
   spi_csb_proc : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         spi_csb_o <= '1';
      elsif (clk_i'event and clk_i = '1') then
         if (start_delayed = '1') then
            spi_csb_o <= '0';
         elsif (spi_dv = '0') then
            spi_csb_o <= '1';
         end if;
      end if;
   end process spi_csb_proc;
  
   
   -- The bit counter (down) indicates the sub-bit position of the parallel word
   -- currently shifted out.  This is also used to reflect the SPI write process
   -- window.
   
   bit_counter : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         bit_count <= 0;
      elsif (clk_i'event and clk_i = '1') then
         if (spi_start_i = '1') then
            bit_count <= spi_pdat_i'length;
         elsif (bit_count /= 0) then
            bit_count <= bit_count - 1;
         end if;
      end if;
   end process bit_counter;
    
   
   -- The dv signal marks the the SPI write process window.  The SPI serial
   -- clock output is only active within this window and nowhere else.
   
   data_valid : process (clk_i, rst_i) 
   begin
      if (rst_i ='1') then
         spi_dv <= '0';
      elsif (clk_i'event and clk_i = '1') then
         if (bit_count /= 0) then
            spi_dv <= '1';
         else
            spi_dv <= '0';
         end if;
      end if;
   end process data_valid;
     
   
   -- Connect the inverted version of input clock as serial clock output when
   -- the SPI write process window is activated.  The inverted version is used
   -- to satisfy the set up and hold time requirements.
   
   spi_sclk_o <= not(clk_i) when spi_dv = '1' else '0';
   
   
end rtl;
