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

-- <Title>
--
-- <revision control keyword substitutions e.g. $Id: tb_counter.vhd,v 1.2 2004/07/21 19:46:15 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/07/21 19:46:15 $>	- <initials $Author: erniel $>
-- $Log: tb_counter.vhd,v $
-- Revision 1.2  2004/07/21 19:46:15  erniel
-- updated counter component
-- added procedures to testbench
--
-- Revision 1.1  2004/03/23 03:15:45  erniel
-- Initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_COUNTER is
end TB_COUNTER;

architecture BEH of TB_COUNTER is

   component COUNTER

      generic(MAX         : integer := 255;
              STEP_SIZE   : integer := 1;
              WRAP_AROUND : std_logic := '0';
              UP_COUNTER  : std_logic := '1');

      port(CLK_I     : in std_logic ;
           RST_I     : in std_logic ;
           ENA_I     : in std_logic ;
           LOAD_I    : in std_logic ;
           COUNT_I   : in integer ;
           COUNT_O   : out integer );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK_I     : std_logic := '1';
   signal W_RST_I     : std_logic ;
   signal W_ENA_I     : std_logic ;
   signal W_LOAD_I    : std_logic ;
   signal W_COUNT_I   : integer ;
   signal W_COUNT_O   : integer ;

begin

   DUT : COUNTER

      generic map(MAX   => 255,
                  STEP_SIZE => 2,
                  WRAP_AROUND => '0',
                  UP_COUNTER => '1')

      port map(CLK_I     => W_CLK_I,
               RST_I     => W_RST_I,
               ENA_I     => W_ENA_I,
               LOAD_I    => W_LOAD_I,
               COUNT_I   => W_COUNT_I,
               COUNT_O   => W_COUNT_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
      procedure do_reset is
      begin
         W_RST_I     <= '1';
         W_ENA_I     <= '1';
         W_LOAD_I    <= '0';
         W_COUNT_I   <= 0;
         wait for PERIOD;
         
      end do_reset;
      
      procedure do_load(value : in integer) is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '1';
         W_LOAD_I    <= '1';
         W_COUNT_I   <= value;
         wait for PERIOD;
      
      end do_load;
            
      procedure do_count is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '1';
         W_LOAD_I    <= '0';
         W_COUNT_I   <= 0;
         wait for PERIOD;
         
      end do_count;
      
      procedure do_disable is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '0';
         W_LOAD_I    <= '0';
         W_COUNT_I   <= 0;
         wait for PERIOD;
       
       end do_disable;
                       
   begin
   
      do_reset;
      
      do_count;
      
      wait for PERIOD * 10;
      
      do_disable;
      
      wait for PERIOD * 10;
      
      do_load(64);
      
      do_count;
      
      wait for PERIOD * 10;
      
      do_load(5);
      
      do_count;
      
      wait for PERIOD * 10;
      
      
      assert false report "End of Simulation." severity FAILURE;
      
      wait;
   end process STIMULI;

end BEH;