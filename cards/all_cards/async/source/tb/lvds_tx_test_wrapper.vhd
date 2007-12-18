---------------------------------------------------------------------
-- Copyright (c) 2003 UK Astronomy Technology Centre
--                All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE UK ATC
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- Project:             Scuba 2
-- Author:              Neil Gruending
-- Organisation:        UBC Physics and Astronomy
--
-- Description:
-- Puseudo random LVDS transmitter test.
--
-- Revision History:
--
-- $Log: lvds_tx_test_wrapper.vhd,v $
-- Revision 1.8  2004/07/21 22:30:15  erniel
-- updated counter component
--
-- Revision 1.7  2004/05/31 21:41:54  erniel
-- attempt at making the enable signal control the state transitions
--
-- Revision 1.6  2004/05/30 01:57:15  erniel
-- tweaked state transitions
--
-- Revision 1.5  2004/05/29 21:32:24  erniel
-- added test enable/disable logic
--
-- Revision 1.4  2004/05/29 20:53:02  erniel
-- added timer expired state changes
--
-- Revision 1.3  2004/05/29 00:45:42  erniel
-- modified square wave logic
-- modified counter enable logic
--
-- Revision 1.2  2004/05/28 20:14:02  erniel
-- added extra transmit patterns
--
-- Revision 1.1  2004/04/28 02:54:50  erniel
-- removed unused RS232 interface signals
--
--
-- Mar 07, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.async_pack.all;

library components;
use components.component_pack.all;

entity lvds_tx_test_wrapper is
   port (
      -- basic signals
      rst_i      : in std_logic;   -- reset input
      clk_i      : in std_logic;   -- clock input
      comm_clk_i : in std_logic;   -- fast communications clock input

      en_i : in std_logic;    -- enable signal
      done_o : out std_logic; -- done ouput signal

      -- extended signals
      lvds_o : out std_logic   -- LVDS output bit
   );
end;

architecture behaviour of lvds_tx_test_wrapper is

   -- lvds signals
   signal dat : std_logic_vector(7 downto 0);
   signal we : std_logic;
   signal ack : std_logic;
   signal cyc : std_logic;
   signal busy : std_logic;
   signal stb : std_logic;

   -- clock divider signals
   signal clk_divide : std_logic_vector(2 downto 0);
   signal tx_clk : std_logic;

   -- internal signals
   signal random_ena : std_logic;
   signal random_dat : std_logic_vector(7 downto 0);

   signal count_ena : std_logic;
   signal count_dat : std_logic_vector(7 downto 0);

   -- state machine
   type states is (IDLE, RANDOM, COUNT, SQUARE);
   signal present_state : states;
   signal next_state    : states;

begin

   -- divide comm_clk down to 25 MHz for LVDS transmit
   process(comm_clk_i)
   begin
      if(comm_clk_i'event and comm_clk_i = '1') then
         clk_divide <= clk_divide + 1;
      end if;
   end process;

   tx_clk <= clk_divide(2);  -- divide clock by 8


   -- our LVDS transmitter
   lvds_tx : async_tx
      port map(
         tx_o =>   lvds_o,
         busy_o => busy,
         clk_i =>  tx_clk,
         rst_i =>  rst_i,
         dat_i =>  dat,
         we_i =>   we,
         stb_i =>  stb,
         ack_o =>  ack,
         cyc_i =>  cyc
      );

   -- we don't use the cyc signal
   cyc <= '1';

   -- our random number generator
   lfsr : prand
      generic map (size => 8)
      port map (
         clr_i => rst_i,
         clk_i => tx_clk,
         en_i =>  random_ena,
         out_o => random_dat
      );

   -- counter
   counter: process(rst_i, tx_clk)
   begin
      if(rst_i = '1') then
         count_dat <= "00000000";
      elsif(tx_clk'event and tx_clk = '1') then
         if(count_ena = '1') then
            count_dat <= count_dat + 1;
         end if;
      end if;
   end process counter;

   done_o <= en_i;

   state_FF: process(rst_i, en_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(en_i'event and en_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;

   state_NS: process(present_state)
   begin
      next_state <= present_state;

      case present_state is
         when IDLE =>   next_state <= RANDOM;
         when RANDOM => next_state <= COUNT;
         when COUNT =>  next_state <= SQUARE;
         when SQUARE => next_state <= RANDOM;
         when others => next_state <= RANDOM;
      end case;
   end process state_NS;

   with present_state select
      dat <= count_dat when COUNT,
             random_dat when RANDOM,
             "00011100" when SQUARE,
             "00000000" when others;

   stb <= (not ack and not busy) when (present_state = RANDOM or present_state = COUNT or present_state = SQUARE) else '0';
   we  <= (not ack and not busy) when (present_state = RANDOM or present_state = COUNT or present_state = SQUARE) else '0';

   random_ena <= ack when present_state = RANDOM else '0';
   count_ena  <= ack when present_state = COUNT  else '0';

end behaviour;