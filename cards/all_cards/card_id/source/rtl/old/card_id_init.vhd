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

-- init_fsm.vhd
--
-- <revision control keyword substitutions e.g. $Id: card_id_init.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:	     SCUBA-2
-- Author:       Ernie Lin
-- Organisation:	UBC
--
-- Description:
-- Implements the initialization phase of the 1-wire bus communication
--
-- Revision history:
-- Jan 15. 2004  - Initial version      - EL
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.sys_param_pack.all;

entity card_id_init is
port(clk          : in std_logic;
     rst          : in std_logic;
     init_start_i : in std_logic;
     init_done_o  : out std_logic;
     data_bi      : inout std_logic);
end card_id_init;

architecture behav of card_id_init is

-- state encoding:
constant IDLE            : std_logic_vector(2 downto 0) := "000";
constant SETUP_RESET     : std_logic_vector(2 downto 0) := "001"; 
constant ASSERT_RESET    : std_logic_vector(2 downto 0) := "010";
constant SETUP_PRESENCE  : std_logic_vector(2 downto 0) := "011";
constant ASSERT_PRESENCE : std_logic_vector(2 downto 0) := "100";
constant DETECTED        : std_logic_vector(2 downto 0) := "101";
constant INIT_DONE       : std_logic_vector(2 downto 0) := "110";

-- state variables:
signal present_state : std_logic_vector(2 downto 0) := "000"; 
signal next_state    : std_logic_vector(2 downto 0) := "000";

-- timing information from specifications:
constant RESET_DURATION_US    : integer := 500;
constant PRESENCE_DURATION_US : integer := 500;
constant SAMPLING_DELAY_US    : integer := 60;

component us_timer
port(clk     : in std_logic;
     timer_reset_i   : in std_logic;
     timer_count_o : out integer);
end component;

signal timer_reset : std_logic;
signal timer_value : integer;

begin

   u0: us_timer
      port map(clk => clk,
               timer_reset_i => timer_reset,
               timer_count_o => timer_value);

   state_FF: process(clk, rst)
   begin
      if(rst = '1') then
         present_state <= IDLE;
      elsif(clk'event and clk = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;

   next_state_logic: process(present_state, timer_value, init_start_i, data_bi)
   begin
      case present_state is

        when IDLE => 
            if(init_start_i = '1') then
               next_state <= ASSERT_RESET;
            else
               next_state <= IDLE;
            end if;

--         when IDLE => 
--            if(init_start_i = '1') then
--               next_state <= SETUP_RESET;
--            end if;
--
--         when SETUP_RESET =>
--            next_state <= ASSERT_RESET;

         when ASSERT_RESET =>
            if(timer_value = RESET_DURATION_US) then
               -- timer expired -> set up presence pulse detect phase
               next_state <= SETUP_PRESENCE;
            else
               -- timer not expired -> wait for reset pulse phase to finish
               next_state <= ASSERT_RESET;
            end if;

         when SETUP_PRESENCE =>
            next_state <= ASSERT_PRESENCE;

         when ASSERT_PRESENCE =>
               if(timer_value > SAMPLING_DELAY_US) then
                  if(timer_value = PRESENCE_DURATION_US) then
                     -- timer expired and presence pulse not detected
                     next_state <= IDLE;
                  elsif(data_bi = '0') then
                     -- presence pulse detected
                     next_state <= DETECTED;
                  else
                     -- timer not expired and presence pulse not detected -> continue to wait
                     next_state <= ASSERT_PRESENCE;
                  end if;
               else
                  next_state <= ASSERT_PRESENCE;
               end if;      

         when DETECTED =>
            if(timer_value = PRESENCE_DURATION_US) then
               -- timer expired -> initialization complete
               next_state <= INIT_DONE;
            else
               -- timer not expired -> wait for presence pulse detect phase to finish
               next_state <= DETECTED;
            end if;
 
         when INIT_DONE =>
            next_state <= IDLE;
            --next_state <= INIT_DONE;

         when others =>
            next_state <= IDLE;

      end case;
   end process next_state_logic;

   output_logic: process(present_state)
   begin
      case present_state is

         when IDLE =>
            data_bi     <= 'Z';
            timer_reset <= '1';
            init_done_o <= '0';

--
--         when IDLE =>
--            data_bi     <= 'Z';
--            timer_reset <= '0';
--            init_done_o <= '0';
--                        
--         when SETUP_RESET =>
--            data_bi     <= 'Z';
--            timer_reset <= '1';
--            init_done_o <= '0';
--                        
         when ASSERT_RESET =>
            data_bi     <= '0';
            timer_reset <= '0';
            init_done_o <= '0';
            
         when SETUP_PRESENCE =>
            data_bi     <= 'Z';
            timer_reset <= '1';
            init_done_o <= '0';
                        
         when ASSERT_PRESENCE =>
            data_bi     <= 'Z';
            timer_reset <= '0';
            init_done_o <= '0';
                        
         when DETECTED =>
            data_bi     <= 'Z';
            timer_reset <= '0';
            init_done_o <= '0';
                        
         when INIT_DONE =>
            data_bi     <= 'Z';
            timer_reset <= '1';
            --timer_reset <= '0';
            init_done_o <= '1';
                        
         when others =>
            data_bi     <= 'Z';
            timer_reset <= '1';
            init_done_o <= '0';
                        
      end case;
   end process output_logic;

end behav;