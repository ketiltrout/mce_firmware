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
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_CRC is
end TB_CRC;

architecture BEH of TB_CRC is

   component CRC

      generic(POLY_WIDTH    : integer  := 8 ;
              DATA_LENGTH   : integer  := 64 );

      port(CLK       : in std_logic ;
           RST       : in std_logic ;
           CLR_I     : in std_logic ;
           ENA_I     : in std_logic ;
           DATA_I    : in std_logic ;
           POLY_I    : in std_logic_vector ( POLY_WIDTH downto 1 );
           DONE_O    : out std_logic ;
           VALID_O   : out std_logic );

   end component;


   constant PERIOD : time := 20 ns;
   constant POLY_WIDTH : integer := 32;
   
   signal W_CLK       : std_logic  := '1';
   signal W_RST       : std_logic ;
   signal W_CLR_I     : std_logic ;
   signal W_ENA_I     : std_logic ;
   signal W_DATA_I    : std_logic ;
   signal W_POLY_I    : std_logic_vector ( POLY_WIDTH downto 1 );
   signal W_DONE_O    : std_logic ;
   signal W_VALID_O   : std_logic ;

begin

   DUT : CRC

      generic map(POLY_WIDTH    => 32 ,
                  DATA_LENGTH   => 64 )

      port map(CLK       => W_CLK,
               RST       => W_RST,
               CLR_I     => W_CLR_I,
               ENA_I     => W_ENA_I,
               DATA_I    => W_DATA_I,
               POLY_I    => W_POLY_I,
               DONE_O    => W_DONE_O,
               VALID_O   => W_VALID_O);

   W_CLK <= not W_CLK after PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RST       <= '1';
      W_CLR_I     <= '0';
      W_ENA_I     <= '1';
      W_DATA_I    <= '0';
      W_POLY_I    <= (others => '0');
      
      wait for PERIOD;
      
      W_RST       <= '0';
      
      wait for PERIOD;     
   end do_reset;
   
   procedure do_calculate(data : in std_logic_vector(63 downto 0)) is
   begin
      W_CLR_I     <= '0'; 
--      W_POLY_I    <= "00110001";                          -- Maxim CRC polynomial
      W_POLY_I    <= "00000100110000010001110110110111";  -- CRC-32 polynomial
         
      for i in 0 to 63 loop
         W_DATA_I <= data(i);
         
         wait for PERIOD;
      end loop;
   end do_calculate;
   
   procedure do_clear is
   begin
      W_CLR_I     <= '1';
      
      wait for PERIOD;
   end do_clear;


   begin
   
      do_reset;
   
      do_clear;
   
      do_calculate("0101101001010101010001001110100111101111111111100000000000001110");  -- this works with CRC-32 polynomial
      
      wait for PERIOD * 10;
      
      do_clear;
   
      do_calculate("1010011010100010111010111000111110011101011101001011111110101010");  -- this works with Maxim CRC polynomial

      wait for PERIOD * 10;
              
   
      assert false report "End of simulation." severity FAILURE;
      
      wait;
   end process STIMULI;

end BEH;

configuration CFG_TB_CRC of TB_CRC is
   for BEH
   end for;
end CFG_TB_CRC;
