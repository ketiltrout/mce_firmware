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
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_DISPATCH_TEST is
end TB_DISPATCH_TEST;

architecture BEH of TB_DISPATCH_TEST is

   component DISPATCH_TEST
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

   DUT : DISPATCH_TEST
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
      
      do_receive("10101010101010100000000000000001");  -- starting word
      do_receive("00000000000000000000000000000000");  -- command parameters
      do_receive("00000000000000000000000000000000");  -- data word
      do_receive("01010100010101011101111000000101");  -- checksum word (0x5455DE05 for this sequence)

      wait for PERIOD * 20;
      
      do_receive("10101010101010100000000000000001");  
      do_receive("00000000000000000000000000000000");  
      do_receive("00000000000000000000000000000000");  
      do_receive("01010100010101011101111000000101");  -- checksum word (0x5455DE05 for this sequence)
      
      assert false report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;