-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- tb_sram.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for SRAM model
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_SRAM is
end TB_SRAM;

architecture BEH of TB_SRAM is

   component SRAM
      port(ADDRESS   : in std_logic_vector ( 19 downto 0 );
           DATA      : inout std_logic_vector ( 15 downto 0 );
           N_BHE     : in std_logic ;
           N_BLE     : in std_logic ;
           N_OE      : in std_logic ;
           N_WE      : in std_logic ;
           N_CE1     : in std_logic ;
           CE2       : in std_logic );

   end component;


   constant PERIOD : time := 10 ns;

   signal W_ADDRESS   : std_logic_vector ( 19 downto 0 );
   signal W_DATA      : std_logic_vector ( 15 downto 0 );
   signal W_N_BHE     : std_logic ;
   signal W_N_BLE     : std_logic ;
   signal W_N_OE      : std_logic ;
   signal W_N_WE      : std_logic ;
   signal W_N_CE1     : std_logic ;
   signal W_CE2       : std_logic ;

begin

   DUT : SRAM
      port map(ADDRESS   => W_ADDRESS,
               DATA      => W_DATA,
               N_BHE     => W_N_BHE,
               N_BLE     => W_N_BLE,
               N_OE      => W_N_OE,
               N_WE      => W_N_WE,
               N_CE1     => W_N_CE1,
               CE2       => W_CE2);

   STIMULI : process
   begin
   
      W_N_BHE     <= '0';
      W_N_BLE     <= '0';
      W_N_OE      <= '0';
      W_N_CE1     <= '0';
      W_CE2       <= '1';

      ------------------------------------------------------         
      -- Do some writes:
      
      W_ADDRESS   <= "00000000000000000000";
      W_DATA      <= "0000111100001111";
      W_N_WE      <= '0';

      wait for 20 ns;

      W_ADDRESS   <= "00000000000000000001";
      W_DATA      <= "0000000100100011";
      W_N_WE      <= '0';
      
      wait for 20 ns;
     
      W_ADDRESS   <= "00000000000000000010";
      W_DATA      <= "1011101010111110";
      W_N_WE      <= '0';
      
      wait for 20 ns; 
      
      ------------------------------------------------------
      -- Do some reads:
      
      W_DATA      <= (others => 'Z');
      
      
      W_ADDRESS   <= "00000000000000000000";
      W_N_WE      <= '1';
      
      wait for 20 ns;
      
      W_ADDRESS   <= "00000000000000000001";
      W_N_WE      <= '1';
      
      wait for 20 ns;
      
      W_ADDRESS   <= "00000000000000000010";
      W_N_WE      <= '1';
      
      wait for 20 ns;
      
      ------------------------------------------------------      
      -- read from empty location:
      
      W_ADDRESS   <= "00000000000000000011";
      W_N_WE      <= '1';
      
      wait for 20 ns;
      
      ------------------------------------------------------      
      -- write to empty location:
      
      W_ADDRESS   <= "00000000000000000000";
      W_DATA      <= "1100000011011110";
      W_N_WE      <= '0';
      
      wait for 20 ns;
      
      ------------------------------------------------------
      -- read from just-filled location:
        
      W_DATA      <= (others => 'Z');
          
      W_ADDRESS   <= "00000000000000000000";
      W_N_WE      <= '1';
      
      wait for 20 ns;
      
      wait;
   end process STIMULI;

end BEH;