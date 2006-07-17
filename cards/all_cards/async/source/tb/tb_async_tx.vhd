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
-- tb_async_tx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- testbench for async transmitter module
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity TB_ASYNC_TX is
end TB_ASYNC_TX;

architecture BEH of TB_ASYNC_TX is

   component ASYNC_TX
      port(TX_O     : out std_logic ;
           BUSY_O   : out std_logic ;
           TX_CLK_I : in std_logic ;
           RST_I    : in std_logic ;
           DAT_I    : in std_logic_vector ( 7 downto 0 );
           STB_I    : in std_logic );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_TX_O     : std_logic ;
   signal W_BUSY_O   : std_logic ;
   signal W_TX_CLK_I : std_logic := '1';
   signal W_RST_I    : std_logic ;
   signal W_DAT_I    : std_logic_vector ( 7 downto 0 );
   signal W_STB_I    : std_logic ;

begin

   DUT : ASYNC_TX
      port map(TX_O     => W_TX_O,
               BUSY_O   => W_BUSY_O,
               TX_CLK_I => W_TX_CLK_I,
               RST_I    => W_RST_I,
               DAT_I    => W_DAT_I,
               STB_I    => W_STB_I);

   W_TX_CLK_I <= not W_TX_CLK_I after PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RST_I    <= '1';
      W_DAT_I    <= (others => '0');
      W_STB_I    <= '0';

      
      wait for PERIOD;
   end do_reset;
   
   procedure do_transmit(data : in std_logic_vector(7 downto 0)) is
   begin
      W_RST_I    <= '0';
      W_DAT_I    <= data;
      W_STB_I    <= '1';
      wait for PERIOD*3;
      
      W_RST_I    <= '0';
      W_DAT_I    <= (others => '0');
      W_STB_I    <= '0';
      
      wait until W_BUSY_O = '0';
      
      wait for PERIOD*10;
      
   end do_transmit;
   
   begin
   
      do_reset;
      
      do_transmit("11110000");
      do_transmit("01010101");
      do_transmit("00011100");
      
      assert false report "End of Simulation." severity failure;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;
