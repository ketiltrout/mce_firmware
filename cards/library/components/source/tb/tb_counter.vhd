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

library components;
use components.component_pack.all;

entity TB_COUNTER is
end TB_COUNTER;

architecture BEH of TB_COUNTER is

   constant PERIOD : time := 20 ns;
   constant WIDTH  : integer := 4;
   
   signal W_CLK_I     : std_logic := '1';
   signal W_RST_I     : std_logic ;
   signal W_ENA_I     : std_logic ;
   signal W_UP_I      : std_logic ;
   signal W_LOAD_I    : std_logic ;
   signal W_CLEAR_I   : std_logic ;
   signal W_COUNT_I   : std_logic_vector(WIDTH-1 downto 0) ;
   signal W_COUNT_O   : std_logic_vector(WIDTH-1 downto 0) ;

begin

   -- to test other counters, uncomment the appropriate instantiation:
   
   dut : binary_counter
   generic map(WIDTH => WIDTH)
      
--   dut : grey_counter
--   generic map(WIDTH => WIDTH)
--               
--   dut : ring_counter  -- normal ring counter mode
--   generic map(WIDTH => WIDTH,
--               MODE  => '0')
--                  
--   dut : ring_counter  -- johnson counter mode
--   generic map(WIDTH => WIDTH,
--               MODE  => '1')
               
   port map(CLK_I     => W_CLK_I,
            RST_I     => W_RST_I,
            ENA_I     => W_ENA_I,
            UP_I      => W_UP_I,
            LOAD_I    => W_LOAD_I,
            CLEAR_I   => W_CLEAR_I,
            COUNT_I   => W_COUNT_I,
            COUNT_O   => W_COUNT_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
      procedure do_reset is
      begin
         W_RST_I     <= '1';
         W_ENA_I     <= '0';
         W_UP_I      <= '0';
         W_LOAD_I    <= '0';
         W_CLEAR_I   <= '0';
         W_COUNT_I   <= (others => '0');
         wait for PERIOD;
      end do_reset;
      
      procedure do_load(value : in std_logic_vector(WIDTH-1 downto 0)) is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '1';
         W_UP_I      <= '0';
         W_LOAD_I    <= '1';
         W_CLEAR_I   <= '0';
         W_COUNT_I   <= value;
         wait for PERIOD;
      end do_load;
            
      procedure do_count_up is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '1';
         W_UP_I      <= '1';
         W_LOAD_I    <= '0';
         W_CLEAR_I   <= '0';
         W_COUNT_I   <= (others => '0');
         wait for PERIOD;
      end do_count_up;
      
      procedure do_count_down is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '1';
         W_UP_I      <= '0';
         W_LOAD_I    <= '0';
         W_CLEAR_I   <= '0';
         W_COUNT_I   <= (others => '0');
         wait for PERIOD;
      end do_count_down;
       
      procedure do_disable is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '0';
         W_UP_I      <= '0';
         W_LOAD_I    <= '0';
         W_CLEAR_I   <= '0';
         W_COUNT_I   <= (others => '0');
         wait for PERIOD;
       end do_disable;
       
      procedure do_clear_up is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '0';
         W_UP_I      <= '1';
         W_LOAD_I    <= '0';
         W_CLEAR_I   <= '1';
         W_COUNT_I   <= (others => '0');
         wait for PERIOD;
       end do_clear_up;   
       
      procedure do_clear_down is
      begin
         W_RST_I     <= '0';
         W_ENA_I     <= '0';
         W_UP_I      <= '0';
         W_LOAD_I    <= '0';
         W_CLEAR_I   <= '1';
         W_COUNT_I   <= (others => '0');
         wait for PERIOD;
       end do_clear_down;
                    
   begin
   
      do_reset;
      
      do_count_up;
      
      wait for PERIOD * 10;
      
      do_disable;
      
      wait for PERIOD * 10;
      
      do_load("0010");
      
      do_count_down;
      
      wait for PERIOD * 10;
      
      do_load("0101");
      
      do_count_up;
      
      wait for PERIOD * 10;
      
      do_clear_up;
      
      do_count_down;
      
      wait for PERIOD * 10;
      
      do_clear_down;
      
      do_count_up;
      
      wait for PERIOD * 10;
      
      assert false report "End of Simulation." severity FAILURE;
      
      wait;
   end process STIMULI;

end BEH;