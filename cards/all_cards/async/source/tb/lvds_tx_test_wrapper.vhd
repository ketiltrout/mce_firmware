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
      rst_i : in std_logic;   -- reset input
      clk_i : in std_logic;   -- clock input
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
   
   -- internal signals
   signal enabled : std_logic;
   signal rnd_clk : std_logic;
   
   signal random_ena : std_logic;
   signal random_dat : std_logic_vector(7 downto 0);
   
   signal count_ena : std_logic;
   signal count_dat : std_logic_vector(7 downto 0);
   
   -- state machine
   type states is (IDLE, RANDOM, COUNT, SQUARE);
   signal present_state : states;
   signal next_state    : states;
   
   signal timer : std_logic_vector(27 downto 0);

begin

   -- our LVDS transmitter
   lvds_tx : async_tx
      port map(
         tx_o =>   lvds_o,
         busy_o => busy,
         clk_i =>  clk_i,
         rst_i =>  rst_i,
         dat_i =>  dat,
         we_i =>   we,
         stb_i =>  stb,
         ack_o =>  ack,
         cyc_i =>  cyc
      );
      
   -- our random number generator
   lfsr : prand
      generic map (size => 8)
      port map (
         clr_i => rst_i,
         clk_i => clk_i,
         en_i =>  random_ena,
         out_o => random_dat
      );
      
   -- we don't use the cyc signal
   cyc <= '1';
   
   -- counter
   counter: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         count_dat <= "00000000";
      elsif(clk_i'event and clk_i = '1') then
         if(count_ena = '1') then
            count_dat <= count_dat + 1;
         end if;
      end if;
   end process counter;
   
--   -- the random counter should only tick if we are enabled
--   rnd_clk <= lvds_ack and lvds_stb and enabled;
   
--   -- test controls the state of the test
--   test : process (rst_i, en_i)
--   begin
--      if (rst_i = '1') then
--         enabled <= '0';
--      elsif Rising_Edge(en_i) then
--         enabled <= enabled xor '1';
--      end if;
--   end process test;
   
   -- done_flag controls the done output
   done_flag : process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         done_o <= '0';
      elsif Rising_Edge(clk_i) then
         done_o <= en_i;
      end if;
   end process done_flag;
   
--   -- lvds_strobe controls the lvds strobe lines
--   lvds_strobe : process (rst_i, clk_i)
--   begin
--      if (rst_i = '1') then
--         lvds_we <= '0';
--         lvds_stb <= '0';
--      elsif Rising_Edge(clk_i) then
--         lvds_we <= not(lvds_ack or lvds_busy) and enabled;
--         lvds_stb <= not(lvds_ack or lvds_busy) and enabled;
--      end if;
--   end process lvds_strobe;
   
   process(clk_i)
   begin
      if(clk_i'event and clk_i = '1') then
         timer <= timer + 1;
      end if;
   end process;

   
   state_FF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         if(timer = "1111111111111111111111111111") then
            present_state <= next_state;
         end if;
      end if;
   end process state_FF;
   
   state_NS: process(present_state)
   begin
      case present_state is
         when IDLE =>   next_state <= RANDOM;
         when RANDOM => next_state <= COUNT;
         when COUNT =>  next_state <= SQUARE;
         when SQUARE => next_state <= IDLE;
         when others => next_state <= IDLE;
      end case;
   end process state_NS;
   
   -- state outputs:
   -- counter enable
   -- random enable
   -- transmit data
   -- transmit stb
   -- transmit we
   
   with present_state select
      dat <= count_dat when COUNT,
             random_dat when RANDOM,
             "00011100" when SQUARE,
             "00000000" when others;
   
   state_out: process(present_state, ack, busy)
   begin
      case present_state is
         when IDLE =>   count_ena  <= '0';
                        random_ena <= '0';
                        stb        <= '0';
                        we         <= '0';
                        
         when RANDOM => count_ena  <= '0';
                        random_ena <= ack;
                        stb        <= not ack and not busy;
                        we         <= not ack and not busy;
                        
         when COUNT =>  count_ena  <= ack;
                        random_ena <= '0';
                        stb        <= not ack and not busy;
                        we         <= not ack and not busy;
                        
         when SQUARE => count_ena  <= '0';
                        random_ena <= '0';
                        stb        <= not ack and not busy;
                        we         <= not ack and not busy;
                        
         when others => count_ena  <= '0';
                        random_ena <= '0';
                        stb        <= '0';
                        we         <= '0';
      end case;
   end process state_out;      
end;
