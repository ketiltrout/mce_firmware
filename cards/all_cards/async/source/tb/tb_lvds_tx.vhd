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
-- tb_lvds_tx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for LVDS transmit module
--
-- Revision history:
-- 
-- $Log: tb_lvds_tx.vhd,v $
-- Revision 1.1  2004/06/17 01:29:58  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_LVDS_TX is
end TB_LVDS_TX;

architecture BEH of TB_LVDS_TX is

   component LVDS_TX
      port(CLK_I        : in std_logic ;
           COMM_CLK_I   : in std_logic ;
           RST_I        : in std_logic ;
           DAT_I        : in std_logic_vector ( 31 downto 0 );
           RDY_I        : in std_logic ;
           BUSY_O       : out std_logic ;
           LVDS_O       : out std_logic );

   end component;


   constant PERIOD : time := 40 ns;
   constant COMM_PERIOD : time := 10 ns;

   signal W_CLK_I        : std_logic := '1';
   signal W_COMM_CLK_I   : std_logic := '1';
   signal W_RST_I        : std_logic ;
   signal W_DAT_I        : std_logic_vector ( 31 downto 0 );
   signal W_RDY_I        : std_logic ;
   signal W_BUSY_O       : std_logic ;
   signal W_LVDS_O       : std_logic ;

begin

   DUT : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               COMM_CLK_I   => W_COMM_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_DAT_I,
               RDY_I        => W_RDY_I,
               BUSY_O       => W_BUSY_O,
               LVDS_O       => W_LVDS_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RST_I        <= '1';
      W_DAT_I        <= (others => '0');
      W_RDY_I        <= '0';
      
      wait for PERIOD;
      
      W_RST_I        <= '0';
      W_DAT_I        <= (others => '0');
      W_RDY_I        <= '0';
      
      wait for PERIOD;
      
   end do_reset;
   
   procedure do_transmit (data : in std_logic_vector(31 downto 0)) is
   begin
      W_RST_I        <= '0';
      W_DAT_I        <= data;
      W_RDY_I        <= '1';
      
      wait for PERIOD;
      
      W_RDY_I        <= '0';
      
      wait until W_BUSY_O = '0';
      
      wait for PERIOD;
      
   end do_transmit;
      
   begin
   
      do_reset;
      
      do_transmit("11110000101001010000111100110011");
      
      do_transmit("10101010010101011100110000110011");

      wait for PERIOD;

      assert FALSE report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;
