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
-- tb_rs232_data_tx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for RS232 data transmit controller
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_RS232_DATA_TX is
end TB_RS232_DATA_TX;

architecture BEH of TB_RS232_DATA_TX is

   component RS232_DATA_TX

      generic(WIDTH   : in integer range 1 to 256  := 8 );

      port(CLK_I       : in std_logic ;
           RST_I       : in std_logic ;
           DATA_I      : in std_logic_vector ( WIDTH - 1 downto 0 );
           START_I     : in std_logic ;
           DONE_O      : out std_logic ;
           TX_BUSY_I   : in std_logic ;
           TX_ACK_I    : in std_logic ;
           TX_DATA_O   : out std_logic_vector ( 7 downto 0 );
           TX_WE_O     : out std_logic ;
           TX_STB_O    : out std_logic );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK_I       : std_logic := '1';
   signal W_RST_I       : std_logic ;
   signal W_DATA_I      : std_logic_vector ( 31 downto 0 );
   signal W_START_I     : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_TX_BUSY_I   : std_logic ;
   signal W_TX_ACK_I    : std_logic ;
   signal W_TX_DATA_O   : std_logic_vector ( 7 downto 0 );
   signal W_TX_WE_O     : std_logic ;
   signal W_TX_STB_O    : std_logic ;

begin

   DUT : RS232_DATA_TX

      generic map(WIDTH   => 32 )

      port map(CLK_I       => W_CLK_I,
               RST_I       => W_RST_I,
               DATA_I      => W_DATA_I,
               START_I     => W_START_I,
               DONE_O      => W_DONE_O,
               TX_BUSY_I   => W_TX_BUSY_I,
               TX_ACK_I    => W_TX_ACK_I,
               TX_DATA_O   => W_TX_DATA_O,
               TX_WE_O     => W_TX_WE_O,
               TX_STB_O    => W_TX_STB_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RST_I       <= '1';
      W_DATA_I      <= (others => '0');
      W_START_I     <= '0';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      
      wait for PERIOD * 3;
   end do_reset;
   
   procedure do_start is
   begin
      W_RST_I       <= '0';
      W_DATA_I      <= (others => '0');
      W_START_I     <= '0';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      
      wait for PERIOD * 3;
      
      W_RST_I       <= '0';
      W_DATA_I      <= "11011110101011011011111011101111";
      W_START_I     <= '1';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      
      wait for PERIOD;
      
      W_RST_I       <= '0';
      W_DATA_I      <= (others => '0');
      W_START_I     <= '0';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      
   end do_start;
   
   procedure do_transmit is
   begin
      wait until W_TX_WE_O = '1' and W_TX_STB_O = '1';
      
      wait for 60 ns;
      
      W_RST_I       <= '0';
      W_DATA_I      <= (others => '0');
      W_START_I     <= '0';
      W_TX_BUSY_I   <= '1';
      W_TX_ACK_I    <= '1';
      
      wait for PERIOD;
      
      W_RST_I       <= '0';
      W_DATA_I      <= (others => '0');
      W_START_I     <= '0';
      W_TX_BUSY_I   <= '1';
      W_TX_ACK_I    <= '0';
      
      wait for 300 ns;
      
      W_RST_I       <= '0';
      W_DATA_I      <= (others => '0');
      W_START_I     <= '0';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
   end do_transmit;
   
   begin
      do_reset;
      
      do_start;
      
      do_transmit;
      do_transmit;
      do_transmit;
      do_transmit;
      do_transmit;
      do_transmit;
      do_transmit;
      do_transmit;

      wait for PERIOD * 10;
      
      assert false report "End of simulation" severity failure;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;
