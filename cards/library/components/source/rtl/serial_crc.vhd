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
-- serial_crc.vhd
--
-- Project:		 SCUBA-2
-- Author:		 Ernie Lin
-- Organisation: UBC
--
-- Description:
-- This implements the CRC algorithm for a given CRC polynomial
--
-- Revision history:
--
-- $Log$
--
-- Revision 1.6  2004/08/02 16:02:50  erniel
-- added comments
--
-- Revision 1.5  2004/08/02 14:43:37  erniel
-- added _i and _o to port names to match naming conventions
--
-- Revision 1.4  2004/07/19 21:25:34  erniel
-- added num_bits input port
-- removed DATA_LENGTH generic
--
-- Revision 1.3  2004/07/17 00:57:34  erniel
-- added checksum output port
--
-- Revision 1.2  2004/07/16 23:02:34  erniel
-- conversion to serial data interface
-- modified to allow arbitrary CRC polynomial
-- modified to allow arbitrary data lengths
--
--
-- Jan. 31 2004  - Added control logic  - EL
-- Jan. 29 2004  - Modified interface   - EL
-- Dec. 12 2003  - Initial version      - EL
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------
-- Some commonly used CRC polynomials:
--
-- poly_i = "00000111"                          CRC-8
-- poly_i = "1000110011"                        CRC-10
-- poly_i = "100010110011001"                   CanBus
-- poly_i = "0001000000000101"                  CRC-16
-- poly_i = "0100000000000011"                  CRC-16 Inverted
-- poly_i = "0001000000100001"                  X25
-- poly_i = "00000100110000010001110110110111"  CRC-32
-- poly_i = "00110001"                          Custom (for Maxim DS18S20)
--
------------------------------------------------------------------------

entity serial_crc is
generic(POLY_WIDTH : integer := 8);
port(clk_i  : in std_logic;
     rst_i  : in std_logic;
     clr_i  : in std_logic;
     ena_i  : in std_logic;
     
     poly_i     : in std_logic_vector(POLY_WIDTH downto 1);
     data_i     : in std_logic;
     num_bits_i : in integer;
     done_o     : out std_logic;
     valid_o    : out std_logic;
     checksum_o : out std_logic_vector(POLY_WIDTH downto 1));
end serial_crc;
	
architecture behav of serial_crc is

signal crc_reg  : std_logic_vector(1 to POLY_WIDTH);
signal crc_temp : std_logic_vector(1 to POLY_WIDTH);

signal valid_temp : std_logic_vector(1 to POLY_WIDTH-1);

signal bit_count : integer;

begin
   
   ---------------------------------------------------------
   -- Implement CRC feedback logic
   --
   -- Example with Maxim DS18S20 (refer to datasheet pg. 7)
   -- (dff(1) is MSB, dff(8) is LSB)
   --                                          i  poly_i(i)
   -- data_i xor dff(8)            -> dff(1)   1     1
   --                       dff(1) -> dff(2)   2     0
   --                       dff(2) -> dff(3)   3     0
   --                       dff(3) -> dff(4)   4     0
   -- data_i xor dff(8) xor dff(4) -> dff(5)   5     1
   -- data_i xor dff(8) xor dff(5) -> dff(6)   6     1
   --                       dff(6) -> dff(7)   7     0
   --                       dff(7) -> dff(8)   8     0
   --
   
   crc_gen: for i in 1 to POLY_WIDTH generate
      crc_lsb: if i = 1 generate
         crc_temp(i) <= data_i xor crc_reg(POLY_WIDTH);
      end generate;
      
      crc_others: if i /= 1 generate
         with poly_i(i) select
            crc_temp(i) <= crc_reg(i-1) when '0',
                           crc_reg(i-1) xor data_i xor crc_reg(POLY_WIDTH) when others;
      end generate;
   end generate;
   
   ---------------------------------------------------------
   -- Implement CRC valid bit (valid if checksum = 0)
   --
   -- (NOR is "= 0" operator)
   --
      
   valid_gen: for i in 1 to POLY_WIDTH generate
      valid_lsb: if i = 1 generate
         valid_temp(i) <= crc_reg(i);
      end generate;
      
      valid_mid: if i > 1 and i < POLY_WIDTH generate
         valid_temp(i) <= valid_temp(i-1) or crc_reg(i);
      end generate;
      
      valid_msb: if i = POLY_WIDTH generate
         valid_o <= not(valid_temp(i-1) or crc_reg(i));
      end generate;
   end generate;
   
   ---------------------------------------------------------
   -- Implement CRC checksum register
   --
   
   reg_update: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         crc_reg <= (others => '0');
         bit_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(ena_i = '1') then
            if(clr_i = '1') then
               crc_reg <= (others => '0');
               bit_count <= 0;
            else               
               crc_reg <= crc_temp;
               bit_count <= bit_count + 1;
            end if;
         end if;
      end if;
   end process reg_update;
   
   done_o <= '1' when bit_count = num_bits_i else '0';
   
   checksum_o <= crc_reg when bit_count = num_bits_i else (others => '0');
   
end behav;