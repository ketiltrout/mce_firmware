-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
-- 
--
-- <revision control keyword substitutions e.g. $Id: tb_fibre_rx.vhd,v 1.3 2004/10/13 10:38:21 dca Exp $>
--
-- Project: Scuba 2
-- Author: David Atkinson
-- Organisation: UK ATC
--
-- Title
-- tb_fibre_rx
--
-- Description:
-- Test bed for fibre_rx
--
-- Revision history:
-- <date $Date: 2004/10/13 10:38:21 $> - <text> - <initials $Author: dca $>

-- $ Log: tb_fibre_rx.vhd,v $

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_FIBRE_RX is
end TB_FIBRE_RX;

architecture BEH of TB_FIBRE_RX is

   component FIBRE_RX
      port(CLK_I            : in std_logic ;
           RST_I            : in std_logic ;
           DAT_O            : out std_logic_vector ( 31 downto 0 );
           RDY_O            : out std_logic ;
           ACK_I            : in std_logic ;
           FIBRE_REFCLK_O   : out std_logic ;
           FIBRE_CLKR_I     : in std_logic ;
           FIBRE_DATA_I     : in std_logic_vector ( 7 downto 0 );
           FIBRE_NRDY_I     : in std_logic ;
           FIBRE_RVS_I      : in std_logic ;
           FIBRE_RSO_I      : in std_logic ;
           FIBRE_SC_ND_I    : in std_logic );

   end component;


   constant CLK_PERIOD       : time := 20 ns;
   constant FIBRE_CLK_PERIOD : time := 40 ns;

   signal W_CLK_I            : std_logic := '1';
   signal W_FIBRE_CLK_I      : std_logic := '1';
   signal W_FIBRE_CLKR_I     : std_logic := '1';
   
   signal W_RST_I            : std_logic ;
   signal W_DAT_O            : std_logic_vector ( 31 downto 0 );
   signal W_RDY_O            : std_logic ;
   signal W_ACK_I            : std_logic ;
   signal W_FIBRE_REFCLK_O   : std_logic ;
   signal W_FIBRE_DATA_I     : std_logic_vector ( 7 downto 0 );
   signal W_FIBRE_NRDY_I     : std_logic ;
   signal W_FIBRE_RVS_I      : std_logic ;
   signal W_FIBRE_RSO_I      : std_logic ;
   signal W_FIBRE_SC_ND_I    : std_logic ;

begin

   DUT : FIBRE_RX
      port map(CLK_I            => W_CLK_I,
               RST_I            => W_RST_I,
               DAT_O            => W_DAT_O,
               RDY_O            => W_RDY_O,
               ACK_I            => W_ACK_I,
               FIBRE_REFCLK_O   => W_FIBRE_REFCLK_O,
               FIBRE_CLKR_I     => W_FIBRE_CLKR_I,
               FIBRE_DATA_I     => W_FIBRE_DATA_I,
               FIBRE_NRDY_I     => W_FIBRE_NRDY_I,
               FIBRE_RVS_I      => W_FIBRE_RVS_I,
               FIBRE_RSO_I      => W_FIBRE_RSO_I,
               FIBRE_SC_ND_I    => W_FIBRE_SC_ND_I);

   W_CLK_I            <= not W_CLK_I       after CLK_PERIOD/2;
   W_FIBRE_CLK_I      <= not W_FIBRE_CLK_I after FIBRE_CLK_PERIOD/2;
   
   W_FIBRE_CLKR_I     <= W_FIBRE_CLK_I'delayed(30 ns);

   W_FIBRE_RVS_I      <= '0';
   W_FIBRE_RSO_I      <= '1';
            
   STIMULI : process
   
   procedure hotlink_receive(data : std_logic_vector(31 downto 0)) is
   begin
      
      wait until W_FIBRE_CLKR_I = '1';
      wait for 6 ns;
      W_FIBRE_NRDY_I     <= '1';
      W_FIBRE_NRDY_I     <= '0' after 15 ns;
      wait for 7 ns;
      W_FIBRE_DATA_I     <= x"05";
      W_FIBRE_SC_ND_I    <= '1';
      
      wait until W_FIBRE_CLKR_I = '1';
      wait for 6 ns;
      W_FIBRE_NRDY_I     <= '1';
      W_FIBRE_NRDY_I     <= '0' after 15 ns;
      wait for 7 ns;
      W_FIBRE_DATA_I     <= data(7 downto 0);
      W_FIBRE_SC_ND_I    <= '0';
      
      wait until W_FIBRE_CLKR_I = '1';
      wait for 6 ns;
      W_FIBRE_NRDY_I     <= '1';
      W_FIBRE_NRDY_I     <= '0' after 15 ns;
      wait for 7 ns;
      W_FIBRE_DATA_I     <= data(15 downto 8);
      W_FIBRE_SC_ND_I    <= '0';   
   
      wait until W_FIBRE_CLKR_I = '1';
      wait for 6 ns;
      W_FIBRE_NRDY_I     <= '1';
      W_FIBRE_NRDY_I     <= '0' after 15 ns;
      wait for 7 ns;
      W_FIBRE_DATA_I     <= data(23 downto 16);
      W_FIBRE_SC_ND_I    <= '0';
      
      wait until W_FIBRE_CLKR_I = '1';
      wait for 6 ns;
      W_FIBRE_NRDY_I     <= '1';
      W_FIBRE_NRDY_I     <= '0' after 15 ns;
      wait for 7 ns;
      W_FIBRE_DATA_I     <= data(31 downto 24);
      W_FIBRE_SC_ND_I    <= '0';
   
      wait until W_FIBRE_CLKR_I = '1';
      wait for 6 ns;
      W_FIBRE_NRDY_I     <= '1';
      wait for 7 ns;
      W_FIBRE_DATA_I     <= x"05";
      W_FIBRE_SC_ND_I    <= '1';
      
--      wait for FIBRE_CLK_PERIOD*1;
      
   end hotlink_receive;
   
   procedure do_reset is
   begin
      W_RST_I            <= '1';
      
      wait for CLK_PERIOD*2;
      
      W_RST_I            <= '0';
      
   end do_reset;
      
      
   begin
     
      W_ACK_I            <= '1';

      do_reset;
      
      hotlink_receive(x"DEADDEAD");
      hotlink_receive(x"00010002");
      hotlink_receive(x"ABCDEF01");
      hotlink_receive(x"CABB1E00");
      hotlink_receive(x"F00D1234");
      

      wait for FIBRE_CLK_PERIOD*20;
      
      assert false report "Simulation done." severity FAILURE;
      
      wait;
   end process STIMULI;    
   
end BEH;