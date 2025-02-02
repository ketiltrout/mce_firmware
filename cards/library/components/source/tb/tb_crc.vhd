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
-- tb_crc.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for CRC generator
--
-- Revision history:
-- 
-- $Log: tb_crc.vhd,v $
-- Revision 1.7  2005/08/31 22:34:13  erniel
-- added parallel_crc tests
--
-- Revision 1.6  2004/07/28 23:59:16  erniel
-- removed configuration statement at end
--
-- Revision 1.5  2004/07/20 18:15:42  erniel
-- added mid-calculation pauses
--
-- Revision 1.4  2004/07/19 21:27:14  erniel
-- updated crc component
--
-- Revision 1.3  2004/07/17 00:58:37  erniel
-- added checksum output port
--
-- Revision 1.2  2004/07/16 23:24:04  erniel
-- new serial interface
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_CRC is
end TB_CRC;

architecture BEH of TB_CRC is

   component SERIAL_CRC

      generic(POLY_WIDTH    : integer  := 8 );

      port(CLK_I        : in std_logic ;
           RST_I        : in std_logic ;
           CLR_I        : in std_logic ;
           ENA_I        : in std_logic ;
           DATA_I       : in std_logic ;
           NUM_BITS_I   : in integer;
           POLY_I       : in std_logic_vector ( POLY_WIDTH downto 1 );
           DONE_O       : out std_logic ;
           VALID_O      : out std_logic ;
           CHECKSUM_O   : out std_logic_vector ( POLY_WIDTH downto 1 ) );

   end component;

   component PARALLEL_CRC

      generic(POLY_WIDTH    : integer  := 8;
              DATA_WIDTH    : integer  := 8 );

      port(CLK_I        : in std_logic ;
           RST_I        : in std_logic ;
           CLR_I        : in std_logic ;
           ENA_I        : in std_logic ;
           DATA_I       : in std_logic_vector ( DATA_WIDTH downto 1 ) ;
           NUM_WORDS_I  : in integer;
           POLY_I       : in std_logic_vector ( POLY_WIDTH downto 1 );
           DONE_O       : out std_logic ;
           VALID_O      : out std_logic ;
           CHECKSUM_O   : out std_logic_vector ( POLY_WIDTH downto 1 ) );

   end component;

   constant PERIOD : time := 20 ns;
   constant POLY_WIDTH : integer := 8;
   constant DATA_WIDTH : integer := 32;
   
   signal W_CLK          : std_logic  := '1';
   signal W_RST          : std_logic ;
   signal W_POLY         : std_logic_vector ( POLY_WIDTH downto 1 );
   
   signal W_CLR_1        : std_logic ;
   signal W_ENA_1        : std_logic ;
   signal W_DATA_1       : std_logic ;
   signal W_DONE_1       : std_logic ;
   signal W_VALID_1      : std_logic ;
   signal W_CHECKSUM_1   : std_logic_vector ( POLY_WIDTH downto 1 ) ;

   signal W_CLR_2        : std_logic ;
   signal W_ENA_2        : std_logic ;
   signal W_DATA_2       : std_logic_vector ( DATA_WIDTH downto 1 ) ;
   signal W_DONE_2       : std_logic ;
   signal W_VALID_2      : std_logic ;
   signal W_CHECKSUM_2   : std_logic_vector ( POLY_WIDTH downto 1 ) ;

   signal W_NUM_BITS     : integer;
   signal W_NUM_WORDS    : integer;
   
begin

   DUT1 : SERIAL_CRC

      generic map(POLY_WIDTH    => 8 )

      port map(CLK_I        => W_CLK,
               RST_I        => W_RST,
               CLR_I        => W_CLR_1,
               ENA_I        => W_ENA_1,
               DATA_I       => W_DATA_1,
               NUM_BITS_I   => W_NUM_BITS,
               POLY_I       => W_POLY,
               DONE_O       => W_DONE_1,
               VALID_O      => W_VALID_1,
               CHECKSUM_O   => W_CHECKSUM_1);

   DUT2 : PARALLEL_CRC

      generic map(POLY_WIDTH    => 8,
                  DATA_WIDTH    => 32 )

      port map(CLK_I        => W_CLK,
               RST_I        => W_RST,
               CLR_I        => W_CLR_2,
               ENA_I        => W_ENA_2,
               DATA_I       => W_DATA_2,
               NUM_WORDS_I  => W_NUM_WORDS,
               POLY_I       => W_POLY,
               DONE_O       => W_DONE_2,
               VALID_O      => W_VALID_2,
               CHECKSUM_O   => W_CHECKSUM_2);
               
   W_CLK <= not W_CLK after PERIOD/2;
   W_POLY <= "00110001";                          -- Maxim CRC polynomial
--   W_POLY <= "00000100110000010001110110110111";  -- CRC-32 polynomial
         
   STIMULI : process
   procedure do_reset is
   begin
      W_RST        <= '1';
      
      W_CLR_1      <= '0';
      W_ENA_1      <= '0';
      W_DATA_1     <= '0';
      W_NUM_BITS   <= 0;
      
      W_CLR_2      <= '0';
      W_ENA_2      <= '0';
      W_DATA_2     <= (others => '0');
      W_NUM_WORDS  <= 0;      
      
      wait for PERIOD;     
   end do_reset;
   
   procedure do_calculate1(data : in std_logic_vector(63 downto 0)) is
   begin
      W_RST        <= '0';
      
      W_CLR_1      <= '0'; 
      W_ENA_1      <= '1';
      W_NUM_BITS   <= 64;   

      for i in 0 to 31 loop
         W_DATA_1 <= data(i);
         wait for PERIOD;
      end loop;
      
      -- pause for 20 clock periods
      W_ENA_1      <= '0';
      wait for PERIOD * 20;
      
      -- resume
      W_ENA_1      <= '1';
      for i in 32 to 63 loop
         W_DATA_1 <= data(i);
         wait for PERIOD;
      end loop;

      W_ENA_1      <= '0';
      wait for PERIOD * 20;
            
   end do_calculate1;
   
   procedure do_calculate2(data : in std_logic_vector(63 downto 0)) is
   begin
      W_RST        <= '0';
      
      W_CLR_2      <= '0'; 
      W_NUM_WORDS  <= 2;   

      W_ENA_2      <= '1';
      W_DATA_2     <= data(31 downto 0);
      wait for PERIOD;

--      W_ENA_2      <= '1';      
--      for i in 0 to 3 loop
--         W_DATA_2 <= data((i*8)+7 downto i*8);
--         wait for PERIOD;
--      end loop;
      
      -- pause for 20 clock periods
      W_ENA_2      <= '0';
      wait for PERIOD * 20;
      
      W_ENA_2      <= '1';
      W_DATA_2     <= data(63 downto 32);
      wait for PERIOD;
      
--      -- resume
--      W_ENA_2      <= '1';
--      for i in 4 to 7 loop
--         W_DATA_2 <= data((i*8)+7 downto i*8);
--         wait for PERIOD;
--      end loop;

      W_ENA_2      <= '0';
      wait for PERIOD * 20;
            
   end do_calculate2;
   
   procedure do_clear is
   begin
      W_CLR_1      <= '1';
      W_ENA_1      <= '1';
      W_DATA_1     <= '0';
      W_NUM_BITS   <= 0;

      W_CLR_2      <= '1';
      W_ENA_2      <= '1';
      W_DATA_2     <= (others => '0');
      W_NUM_WORDS  <= 0;

      wait for PERIOD;
   end do_clear;


   begin
   
      do_reset;
   
--      do_clear;
--   
--      do_calculate1("0101101001010101010001001110100111101111111111100000000000001110");  -- this works with CRC-32 polynomial
--      
--      wait for PERIOD * 10;
      
      do_clear;
   
      do_calculate1("1010011010100010111010111000111110011101011101001011111110101010");  -- this works with Maxim CRC polynomial
      do_calculate2("1010011010100010111010111000111110011101011101001011111110101010");  -- this works with Maxim CRC polynomial

      wait for PERIOD * 10;
              
   
      assert false report "End of simulation." severity FAILURE;
      
      wait;
   end process STIMULI;

end BEH;
