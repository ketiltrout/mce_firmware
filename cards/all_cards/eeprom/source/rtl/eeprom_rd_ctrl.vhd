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
-- eeprom_rd_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- eeprom read-control block
--
-- This block controls the read operation from AT25128 eeprom. It generates
-- the necessary bit patterns (instructions) and issue an spi_start signal, 
-- then it listens for spi_done and when appropriate it generates a strobe 
-- to send out the data read from the eeprom.
-- The read operation has the following cycles:
-- 1. Issue READ command to eeprom
-- 2. Issue address MSB to eeprom
-- 3. Issue address LSB to eeprom
-- 4. read byte from eeprom
-- 5. if more data needs to be read, go to step 4.
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
use ieee.std_logic_unsigned.all;

library work;
use work.eeprom_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity eeprom_rd_ctrl is
   port ( 
   
      -- global signals
      rst_i                     : in     std_logic;                                    -- global reset
      clk_50_i                  : in     std_logic;                                    -- global clock (50 MHz)
           									    
      -- control signals from eeprom_wbs block
      read_req_i                : in     std_logic;                                    -- trigger a read from eeprom      
      start_addr_i              : in     std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);-- start_address for read or write  
      
      -- interface to spi block
      dat_o                     : out    std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);-- read command to be written to spi if
      spi_wr_start_o            : out    std_logic;                                    -- trigger an spi write byte (read instruction and address)
      spi_rd_start_o            : out    std_logic;                                    -- trigger an spi read byte
      spi_done_i                : in     std_logic;
      
      -- interface to eeprom_admin block
      hold_cs_i                 : in     std_logic;                                    -- indicates whether to hold cs or not for subsequent read operations
      ee_dat_stb_o              : out    std_logic                                     -- strobe for data read from eeprom
   );
end eeprom_rd_ctrl;
      
architecture rtl of eeprom_rd_ctrl is   

   -- internal signal declarations 
   signal rd_cycle                  : std_logic_vector(1 downto 0);
   signal rd_cycle_counter_en       : std_logic;
   signal rd_cycle_counter_clr      : std_logic;
   
   -- FSM variables
   type state is (IDLE, SEND, WAIT_FOR_SPI, READ_DATA, FETCH_DATA, WS1, WS2, WS3);                           
   signal current_state: state;
   signal next_state:    state;
   
begin
   -- read operation FSM    
   state_FF: process(clk_50_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
      elsif(clk_50_i'event and clk_50_i = '1') then
         current_state <= next_state;
      end if;
   end process state_FF;
   
   -- FSM: next state logic
   state_NS: process(current_state, spi_done_i, read_req_i, rd_cycle)
   begin
      next_state <= current_state;
      case current_state is
         when IDLE => 
            if read_req_i = '1' then
               next_state <= SEND;
            end if;
            
         when SEND =>
            next_state <= WAIT_FOR_SPI;
            
         when WAIT_FOR_SPI =>
            if spi_done_i = '1' then
               if (rd_cycle < 2) then
                  next_state <= SEND;
               else
                  next_state <= READ_DATA;
               end if;   
            end if;  
                           
         when READ_DATA =>
            next_state <= FETCH_DATA;            
            
         when FETCH_DATA =>
            if spi_done_i = '1' then 
               next_state <= WS1;
            end if;               
         
         -- wait for wishbone ack to be issued by eeprom_wbs
         when WS1 =>
            next_state <= WS2;
         
         -- wait for wishbone to see if more read is triggered
         when WS2 =>   
            next_state <= WS3;
                 
         when WS3 =>   
            if read_req_i = '1' then
               next_state <= READ_DATA;
            else
               next_state <= IDLE;
            end if;   

         when others =>
            null;

      end case;
   end process state_NS;   

   -- FSM: output logic
   state_out: process(current_state, spi_done_i, rd_cycle,start_addr_i)
   begin
      -- default assignements
      dat_o               <= (others => '0');
      spi_wr_start_o      <= '0';
      spi_rd_start_o      <= '0';
      ee_dat_stb_o        <= '0';
      rd_cycle_counter_en <= '0';
      rd_cycle_counter_clr<= '0';
     
      case current_state is
         when IDLE =>
            rd_cycle_counter_clr <= '1';    

         when SEND =>
            spi_wr_start_o      <= '1';
            data_select: case rd_cycle is
           
               when "00"  => dat_o <= READ_CMD;
                                             
               when "01"  => dat_o <= EEPROM_ADDR_FILLER & start_addr_i(start_addr_i'length-1 downto 8);

               when "10"  => dat_o <= start_addr_i(7 downto 0);                       
                               
               when others => dat_o <= (others => '0');
           
            end case data_select;     
            
         when WAIT_FOR_SPI =>
            if (spi_done_i = '1') then
               rd_cycle_counter_en <= '1';
            end if;   
          
         when READ_DATA =>
               spi_rd_start_o <= '1';
        
         when FETCH_DATA => 
            if (spi_done_i = '1') then
               ee_dat_stb_o <= '1';
            end if;   
         
         when others =>
            null;
      end case;
   end process state_out;   
   
   -- The read cycle keeps tracks of the data that is written to eeprom
   -- rd_cycle = 00 : READ command opcode
   -- rd_cycle = 01 : MSB of address
   -- rd_cycle = 11 : LSB of address
   
   i_rd_cycle_counter: process(clk_50_i, rst_i)
   begin
      if rst_i = '1' then
         rd_cycle <= (others =>'0');
      elsif (clk_50_i'event and clk_50_i = '1') then 
         if (rd_cycle_counter_clr = '1') then
            rd_cycle <= (others=>'0');
         elsif (rd_cycle_counter_en = '1') then
            rd_cycle <= rd_cycle + 1;
         end if;
      end if;
   end process i_rd_cycle_counter;   
     
end rtl;

