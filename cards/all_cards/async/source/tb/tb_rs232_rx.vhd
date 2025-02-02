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
-- tb_rs232_rx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for RS232 receive module
--
-- Revision history:
-- 
-- $Log: tb_rs232_rx.vhd,v $
-- Revision 1.2  2010/09/08 22:36:47  mandana
-- added comm_clk_i to rs232_rx interface. This is 4x115200 PLL-generated clock. rs232_rx block is rewritten to use a fifo to synchronize between clock domains.
-- Note that the main clock is changed to 50MHz because PLL is not instantiated here.
--
-- Revision 1.1  2004/06/18 22:15:29  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_RS232_RX is
end TB_RS232_RX;

architecture BEH of TB_RS232_RX is

   component RS232_RX
      port(CLK_I        : in std_logic ;
           COMM_CLK_I   : in std_logic ;
           RST_I        : in std_logic ;
           DAT_O        : out std_logic_vector ( 7 downto 0 );
           RDY_O        : out std_logic ;
           ACK_I        : in std_logic ;
           RS232_I      : in std_logic );

   end component;

   component RS232_TX
      port(CLK_I        : in std_logic ;
           RST_I        : in std_logic ;
           DAT_I        : in std_logic_vector ( 7 downto 0 );
           RDY_I      : in std_logic ;
           BUSY_O       : out std_logic ;
           RS232_O      : out std_logic );

   end component;

   constant PERIOD : time := 20 ns; -- 50MHz clock, because PLL is not instantiated here.
   --constant COMM_PERIOD : time :=  2170ns;   --corresponds to 115200 baud rate
   constant COMM_PERIOD : time :=  6510ns;   --corresponds to 38400 baud rate
   -- common signals
   signal W_CLK_I        : std_logic := '1';
   signal W_COMM_CLK_I   : std_logic := '1';
   signal W_RST_I        : std_logic ;
   signal W_RS232        : std_logic ;
      
   -- receiver signals
   signal W_DAT_O        : std_logic_vector ( 7 downto 0 );
   signal W_RDY_O        : std_logic ;
   signal W_ACK_I        : std_logic ;
   
   -- transmitter signals
   signal W_DAT_I        : std_logic_vector ( 7 downto 0 );
   signal W_START_I      : std_logic ;
   signal W_DONE_O       : std_logic ;

begin

   DUT : RS232_RX
      port map(CLK_I        => W_CLK_I,
               COMM_CLK_I   => W_COMM_CLK_I,
               RST_I        => W_RST_I,
               DAT_O        => W_DAT_O,
               RDY_O        => W_RDY_O,
               ACK_I        => W_ACK_I,
               RS232_I      => W_RS232);

   tx : RS232_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_DAT_I,
               RDY_I      => W_START_I,
               BUSY_O       => W_DONE_O,
               RS232_O      => W_RS232);
   
   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RST_I        <= '1';
      W_DAT_I        <= (others => '0');
      W_START_I      <= '0';
      W_ACK_I        <= '0';
      
      wait for 100*PERIOD;
      
      W_RST_I        <= '0';
      W_DAT_I        <= (others => '0');
      W_START_I      <= '0';
      W_ACK_I        <= '0';
            
      wait for PERIOD;
   end do_reset;

   procedure do_transmit (data : in std_logic_vector(7 downto 0)) is
   begin
      W_RST_I        <= '0';
      W_DAT_I        <= data;
      W_START_I      <= '1';
      W_ACK_I        <= '0';
      
      wait for PERIOD;
      
      W_START_I      <= '0';
      
      --wait until W_DONE_O = '1';
      wait until W_RDY_O = '1';
      
      
      W_ACK_I <= '1';
      
      wait for 100*PERIOD;
      
      W_ACK_I <= '0';
      
      wait for PERIOD;
            
   end do_transmit;   
   begin

      do_reset;
      
      do_transmit("11110000");
      do_transmit("00001111");
      do_transmit("01010101");
      do_transmit("11111100");
      do_transmit("10100110");
      do_transmit("01100010");
      do_transmit("01100111");
      
      wait for PERIOD*100000;
      
      assert FALSE report "End of simulation." severity FAILURE;
         
--      W_RST_I        <= '0';
--      W_ACK_I        <= '0';
--      W_RS232_I      <= '0';

      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;
