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
-- tb_async_rx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- testbench for async receiver module
--
-- Revision history:
-- 
-- $Log: tb_async_rx.vhd,v $
-- Revision 1.2  2004/06/17 01:31:44  erniel
-- renamed clock signal to rx_clk_i
-- modified timing of stb_i signal
--
-- Revision 1.1  2004/06/11 18:38:47  erniel
-- initial version
-- uses new async tx/rx interface
--
--
-----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity TB_ASYNC_RX is
end TB_ASYNC_RX;

architecture BEH of TB_ASYNC_RX is

   component ASYNC_RX
      port(RX_I      : in std_logic ;
           VALID_O    : out std_logic ;
           ERROR_O   : out std_logic ;
           RX_CLK_I  : in std_logic ;
           RST_I     : in std_logic ;
           DAT_O     : out std_logic_vector ( 7 downto 0 );
           STB_I     : in std_logic);

   end component;


   constant PERIOD : time := 10 ns;

   signal W_RX_I      : std_logic ;
   signal W_VALID_O    : std_logic ;
   signal W_ERROR_O   : std_logic ;
   signal W_RX_CLK_I  : std_logic := '1';
   signal W_RST_I     : std_logic ;
   signal W_DAT_O     : std_logic_vector ( 7 downto 0 );
   signal W_STB_I     : std_logic ;

begin

   DUT : ASYNC_RX
      port map(RX_I      => W_RX_I,
               VALID_O   => W_VALID_O,
               ERROR_O   => W_ERROR_O,
               RX_CLK_I  => W_RX_CLK_I,
               RST_I     => W_RST_I,
               DAT_O     => W_DAT_O,
               STB_I     => W_STB_I);

   W_RX_CLK_I <= not W_RX_CLK_I after PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RX_I      <= '1';    -- idle state of transmit line is high

      W_RST_I     <= '1';
      W_STB_I     <= '0';
         
      wait for PERIOD;
      
      W_RST_I     <= '0';
      W_STB_I     <= '0';
      
      wait for PERIOD;   
         
   end do_reset;
   
   procedure do_receive(data : in std_logic_vector(7 downto 0)) is
   begin
      W_RX_I      <= '0';    -- start bit
      wait for PERIOD * 8;
      W_RX_I      <= data(0);
      wait for PERIOD * 8;
      
      W_STB_I     <= '0';
      
      W_RX_I      <= data(1);
      wait for PERIOD * 8;
      W_RX_I      <= data(2);
      wait for PERIOD * 8;
      W_RX_I      <= data(3);
      wait for PERIOD * 8;
      W_RX_I      <= data(4);
      wait for PERIOD * 8;
      W_RX_I      <= data(5);
      wait for PERIOD * 8;
      W_RX_I      <= data(6);
      wait for PERIOD * 8;
      W_RX_I      <= data(7);
      wait for PERIOD * 8;
      W_RX_I      <= '1';    -- stop bit
      wait for PERIOD * 8;
      
      wait for PERIOD * 10;
      
      W_STB_I     <= '1';
      
      wait for PERIOD * 20;
      
--      W_STB_I     <= '0';
      
   end do_receive;
   
   begin

      do_reset;
      
      wait for PERIOD * 5;
      
      do_receive("00110101");
      
      wait for PERIOD * 5;
      
      do_receive("11110000");
      
      assert false report "End of simulation." severity failure;

      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;
