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
-- tb_dispatch_crc_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for the dispatch CRC datapath
--
-- Revision history:
-- 
-- $Log: tb_dispatch_crc_test.vhd,v $
-- Revision 1.2  2004/08/05 00:26:10  erniel
-- entity renamed
--
-- Revision 1.1  2004/08/04 19:43:19  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_DISPATCH_CRC_TEST is
end TB_DISPATCH_CRC_TEST;

architecture BEH of TB_DISPATCH_CRC_TEST is

   component DISPATCH_CRC_TEST
      port(CLK_I       : in std_logic ;
           RST_I       : in std_logic ;
           RX_DATA     : in std_logic_vector ( 31 downto 0 );
           RX_RDY      : in std_logic ;
           RX_ACK      : out std_logic ;
           WORD_DONE   : out std_logic ;
           CMD_DATA    : out std_logic_vector ( 31 downto 0 ) );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK_I       : std_logic := '1';
   signal W_RST_I       : std_logic ;
   signal W_RX_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_RX_RDY      : std_logic ;
   signal W_RX_ACK      : std_logic ;
   signal W_WORD_DONE   : std_logic ;
   signal W_CMD_DATA    : std_logic_vector ( 31 downto 0 ) ;

begin

   DUT : DISPATCH_CRC_TEST
      port map(CLK_I       => W_CLK_I,
               RST_I       => W_RST_I,
               RX_DATA     => W_RX_DATA,
               RX_RDY      => W_RX_RDY,
               RX_ACK      => W_RX_ACK,
               WORD_DONE   => W_WORD_DONE,
               CMD_DATA    => W_CMD_DATA);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RST_I       <= '1';
      W_RX_DATA     <= (others => '0');
      W_RX_RDY      <= '0';
      
      wait for PERIOD;
   end do_reset;
     
   procedure do_receive(data : in std_logic_vector(31 downto 0)) is
   begin
      W_RST_I       <= '0';
      W_RX_DATA     <= data;
      W_RX_RDY      <= '1';
      
      wait until W_RX_ACK = '1';

      wait for PERIOD;
      
      W_RST_I       <= '0';
      W_RX_DATA     <= (others => '0');
      W_RX_RDY      <= '0';      
            
      wait for PERIOD * 60;   
   end do_receive;
   
   begin

      do_reset;
      
      do_receive("10101010101010100000000000000001");  -- start word
      do_receive("00000000000000000000000000000000");  -- command parameters
      do_receive("00000000000000000000000000000000");  -- data word
      do_receive("01010100010101011101111000000101");  -- checksum word (0x5455DE05 for this packet)

      wait for PERIOD * 20;
      
      do_receive("10101010101010100000000000000011");  -- start word
      do_receive("00000111001000000000000000000000");  -- command parameters
      do_receive("00000000000000000000000000001010");  -- 0x0000000A
      do_receive("00000000000000001101111010101111");  -- 0x0000DEAF
      do_receive("00000000110010101011101100011110");  -- 0x00CABB1E
      do_receive("01110010011010111110010111111111");  -- checksum word (0x726BE5FF for this packet)
      
      wait for PERIOD * 20;
      
      do_receive("10101010101010100000000000000010");  -- start word
      do_receive("00000010010100110000000100000001");  -- command parameters
      do_receive("00001100000110100101010100011100");  -- 0x0C1A551C
      do_receive("00000000000000001100000011011110");  -- 0x0000C0DE
      do_receive("01111110010101011001000000000110");  -- checksum word (0x7E559006 for this packet)
            
      wait for PERIOD * 20;
      
      do_receive("10101010101010100000000000000001");  -- 1 data word
      do_receive("00001100000011110001000000010001");  -- for all BCs
      do_receive("00000000000000001111101010110101");  -- 0x0000FAB5
      do_receive("00100101110000110110010000000100");  -- 0x25C36404
      
      wait for PERIOD * 20;
      
      assert false report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;