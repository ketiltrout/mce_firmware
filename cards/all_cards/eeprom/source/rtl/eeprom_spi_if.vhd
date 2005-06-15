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
-- eeprom_spi_if.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- This is the read/write interface to the EEPROM in SPI format. 
-- The read interface (spi_sdat_i to spi_pdat_o) is an update to 
-- SPI interface used for DACs (Anthony's code, readout card).
-- There is a dedicated read_start and write_start signal to trigger a read or
-- write. Once the operation is completed, an spi_done signal is generated for a 
-- period of one clock cycle. The data read from the eeprom, available in parallel
-- form is valid during spi_done = 1.
-- Since some eeprom operations require consecutive read/write while holding
-- cs low during the whole time, a spi_hold_cs_i is provided to control whether 
-- cs has to be left low after the opertation or not.
-- *NOTE*: This interface is developed based on the assumption that nHOLD and nWP
-- pins are tied high on the board and do NOT have to be controlled by this block.

-- Revision history:
-- Original Code: offset_spi_if.vhd by Anthony Ko
-- <date $Date$>    - <initials $Author$>
-- $Log$
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity eeprom_spi_if is
   
   port ( 
      
      -- global signals
      rst_i                     : in     std_logic;                                  -- global reset
      clk_i                     : in     std_logic;                                  -- global clock
      
      -- handshake signals: start and done
      spi_wr_start_i            : in     std_logic;                                  -- SPI write trigger
      spi_rd_start_i            : in     std_logic;                                  -- SPI read  trigger
      spi_hold_cs_i             : in     std_logic;                                  -- SPI hold cs low after the operation is done
      spi_done_o                : out    std_logic;                                  -- SPI read/write done
      
      -- Parallel data
      spi_wr_pdat_i             : in     std_logic_vector(7 downto 0);               -- SPI parallel write data
      spi_rd_pdat_o             : out    std_logic_vector(7 downto 0);               -- SPI parallel read data
      
      -- SPI signals (chip interface)
      spi_csb_o                 : out    std_logic;                                  -- SPI chip select
      spi_sclk_o                : out    std_logic;                                  -- SPI serial write clock
      spi_sdat_o                : out    std_logic;                                  -- SPI serial write data
      spi_sdat_i                : in     std_logic                                    -- SPI serial read data      
      
      );
        
end eeprom_spi_if;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


architecture rtl of eeprom_spi_if is

   -- internal signal declarations

   signal wr_data_reg   : std_logic_vector(spi_wr_pdat_i'length -1 downto 0);        -- write shift data register 
   signal rd_data_reg   : std_logic_vector(spi_wr_pdat_i'length -1 downto 0);        -- read shift data register
   signal wr_start_delayed : std_logic;                                              -- delayed version of SPI write trigger
   signal rd_start_delayed : std_logic;                                              -- delayed version of SPI read trigger   
   signal spi_dv        : std_logic;                                                 -- SPI read/write process in progress 
   signal wr_bit_count  : integer range 0 to spi_wr_pdat_i'length;                   -- sub-bit position counter for write operation
   signal rd_bit_count  : integer range 0 to spi_rd_pdat_o'length;                   -- sub-bit position counter for read operation
   signal rd_bit_count_reg : integer range 0 to spi_rd_pdat_o'length;                -- sub-bit position counter for read operation
  

begin

   -- This shift register loads the incoming serial data on the NEGATIVE edge.
   -- The register is loaded upon active spi_r_start_i input for 8 consecutive clocks.     
   rd_data_reg_proc : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         rd_data_reg <= (others => '0');
      elsif (clk_i'event and clk_i = '0') then
         if (rd_bit_count_reg /= 0) then
            rd_data_reg((spi_rd_pdat_o'length-1) downto 1) <= rd_data_reg((spi_rd_pdat_o'length-2) downto 0);
            rd_data_reg(0) <= spi_sdat_i;
--         else 
--            rd_data_reg <= (others => '0'); 
         end if;
      end if;
   end process rd_data_reg_proc;
   spi_rd_pdat_o <= rd_data_reg;
  
   -- This shift register loads the input write data in parallel and outputs it serially.
   -- The register is loaded upon active spi_w_start_i input.  Otherwise, each bit
   -- takes its input from its next-lower bit with 0 steering into bit 0.
   
   wr_data_reg_proc : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         wr_data_reg <= (others => '0');
      elsif (clk_i'event and clk_i = '1') then
         if (spi_wr_start_i = '1') then
            wr_data_reg <= spi_wr_pdat_i;
         else
            wr_data_reg((spi_wr_pdat_i'length-1) downto 1) <= wr_data_reg((spi_wr_pdat_i'length-2) downto 0);
            wr_data_reg(0) <= '0';
         end if;
      end if;
   end process wr_data_reg_proc;
   
   
   -- The SPI serial data output is sourced from the most significant bit of the 
   -- data shift register.
   
   spi_sdat_proc : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         spi_sdat_o <= '0';
      elsif (clk_i'event and clk_i = '1') then
         spi_sdat_o <= wr_data_reg(spi_wr_pdat_i'length-1);
      end if;
   end process spi_sdat_proc;
   
   
   -- Delay the SPI write trigger pulse by 1 clock period
   
   spi_wr_start_delayer : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         wr_start_delayed <= '0';
      elsif (clk_i'event and clk_i = '1') then
         wr_start_delayed <= spi_wr_start_i;
      end if;
   end process spi_wr_start_delayer;

   spi_rd_start_delayer : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         rd_start_delayed <= '0';
      elsif (clk_i'event and clk_i = '1') then
         rd_start_delayed <= spi_rd_start_i;
      end if;
   end process spi_rd_start_delayer;
  
   -- Upon active wr_start_delayed pulse, lower the chip select signal (active low).
   -- Hold it at low-level until SPI write data valid window is deasserted.
   -- The window is active for the whole duration of shifting out the parallel data
   -- bits over the serial interface
   
   spi_csb_proc : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         spi_csb_o <= '1';
      elsif (clk_i'event and clk_i = '1') then
         if (wr_start_delayed = '1' or rd_start_delayed = '1') then
            spi_csb_o <= '0';
         elsif (spi_dv = '0' and spi_hold_cs_i = '0' ) then
            spi_csb_o <= '1';
         end if;
      end if;
   end process spi_csb_proc;
  
   
   -- The bit counter (down) indicates the sub-bit position of the parallel word
   -- currently shifted out.  This is also used to reflect the SPI write process
   -- window.
   
   wr_bit_counter : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         wr_bit_count <= 0;
      elsif (clk_i'event and clk_i = '1') then
         if (spi_wr_start_i = '1') then
            wr_bit_count <= spi_wr_pdat_i'length;
         elsif (wr_bit_count /= 0) then
            wr_bit_count <= wr_bit_count - 1;
         end if;
      end if;
   end process wr_bit_counter;
    
   -- The bit counter (down) indicates the sub-bit position of the data being read
   -- currently shifted in.  This is also used to reflect the SPI read process
   -- window.
   
   rd_bit_counter : process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         rd_bit_count <= 0;
         rd_bit_count_reg <= 0;
      elsif (clk_i'event and clk_i = '1') then
         rd_bit_count_reg <= rd_bit_count;
         if (spi_rd_start_i= '1') then
            rd_bit_count <= spi_rd_pdat_o'length;
         elsif (rd_bit_count /= 0) then
            rd_bit_count <= rd_bit_count - 1;
         end if;
      end if;
   end process rd_bit_counter;
   
   
   -- The dv signal marks the SPI write process window.  The SPI serial
   -- clock output is only active within this window and nowhere else.
   
   data_valid : process (clk_i, rst_i) 
   begin
      if (rst_i ='1') then
         spi_dv <= '0';
      elsif (clk_i'event and clk_i = '1') then
         if (wr_bit_count /= 0 or rd_bit_count /= 0 ) then
            spi_dv <= '1';
         else
            spi_dv <= '0';
         end if;
      end if;
   end process data_valid;
     
   read_write_done: process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         spi_done_o <= '0';
      elsif (clk_i'event and clk_i = '1') then
         if (spi_dv = '1' and rd_bit_count = 0 and wr_bit_count = 0) then
           spi_done_o <= '1';
         else
           spi_done_o <= '0';
         end if;
      end if;
   end process read_write_done;      
 
   -- Connect the inverted version of input clock as serial clock output when
   -- the SPI write process window is activated.  The inverted version is used
   -- to satisfy the set up and hold time requirements.
   
   spi_sclk_o <= not(clk_i) when spi_dv = '1' else '0';
   
end rtl;
