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
-- Puseudo random LVDS receiver test.
-- 
-- Revision History:
--
-- $Log: lvds_rx_test_wrapper.vhd,v $
-- Revision 1.2  2004/06/04 00:44:40  erniel
-- *** empty log message ***
--
-- Revision 1.1  2004/05/05 21:28:27  erniel
-- changed entity name from s_lvds_rx
--
--
-- April 15, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.async_pack.all;

library components;
use components.component_pack.all;

entity lvds_rx_test_wrapper is
   port (
      -- basic signals
      rst_i : in std_logic;   -- reset input
      clk_i : in std_logic;   -- clock input
--      rx_clk_i : in std_logic;
      en_i : in std_logic;    -- enable signal
      done_o : out std_logic; -- done ouput signal
      
      -- transmitter signals
      tx_busy_i : in std_logic;  -- transmit busy flag
      tx_ack_i : in std_logic;   -- transmit ack
      tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
      tx_we_o : out std_logic;   -- transmit write flag
      tx_stb_o : out std_logic;  -- transmit strobe flag
      
      -- extended signals
      lvds_i : in std_logic   -- LVDS input bit
   );
end lvds_rx_test_wrapper;

architecture behaviour of lvds_rx_test_wrapper is

   -- lvds signals
   signal lvds_dat : std_logic_vector(7 downto 0);
   signal lvds_we : std_logic;
   signal lvds_ack : std_logic;
   signal lvds_cyc : std_logic;
   signal lvds_flag : std_logic;
   signal lvds_stb : std_logic;
   
   -- random number generator signals
   signal rnd_clk : std_logic;
   signal rnd_dat : std_logic_vector(7 downto 0);
   signal rnd_clr : std_logic;
   
   -- state machine signals
   type states is (SEARCH, SEARCH_RND_CLK, RECEIVE, RECEIVE_RND_CLK, 
                   TX_WRITE1, TX_WAIT1, TX_WRITE2, TX_WAIT2, DONE);
   signal state : states;
   signal next_state : states;
   
   -- internal signals
   signal new_data : std_logic;
   signal hex_data : std_logic_vector(3 downto 0);
   signal good_cnt : integer range 0 to 255;
   
begin

   -- our LVDS receiver
   lvds_rx : async_rx
      port map(
         rx_i => lvds_i,
         flag_o => lvds_flag,
         error_o => open,
--         clk_i => rx_clk_i,
         clk_i => clk_i,
         rst_i => rst_i,
         dat_o => lvds_dat,
         we_i => lvds_we,
         stb_i => lvds_stb,
         ack_o => lvds_ack,
         cyc_i => lvds_cyc
      );
      
   -- our random number generator
   random : prand
      generic map (size => 8)
      port map (
         clr_i => rnd_clr,
         clk_i => clk_i,
         en_i => rnd_clk,
         out_o => rnd_dat
      );

   -- our hex to ascii converter
   hexconv : hex2ascii
      port map (
         hex_i => hex_data,
         ascii_o => tx_data_o
         );
   
   -- we don't use the following signals
   lvds_cyc <= '1';
   lvds_we <= '0';
      
   -- lvds_stb_ctl controls the LVDS strobe line for us
   -- so we can simplify the state machine
   lvds_stb_ctl : process (rst_i, en_i, clk_i)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         lvds_stb <= '0';
      elsif Rising_Edge(clk_i) then
         lvds_stb <= lvds_flag and (not lvds_ack);
      end if;
   end process lvds_stb_ctl;
   
   -- new_data_ctl controls the new_data strobe
   new_data_ctl : process (rst_i, en_i, clk_i)
   variable last : std_logic;
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         new_data <= '0';
         last := '0';
      elsif Rising_Edge(clk_i) then
         new_data <= (lvds_flag xor last) and lvds_flag;
         last := lvds_flag;
      end if;
   end process new_data_ctl;
   
   -- transition to each new state on the rising clock edge.
   state_clk : process (rst_i, en_i, clk_i)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         state <= SEARCH;
      elsif Rising_Edge(clk_i) then
         state <= next_state;
      end if;
   end process state_clk;
   
   -- state logic control
   state_logic : process (state, new_data, lvds_dat, rnd_dat, tx_ack_i)
      variable word_cnt : integer range 0 to 255;
   begin
      case state is
         when SEARCH =>
            -- wait for a byte with all zeros that we can synchronise to
            if ((new_data = '1') and (lvds_dat = rnd_dat)) then
               next_state <= SEARCH_RND_CLK;
               good_cnt <= 1;
               word_cnt := 1;
            else
               next_state <= SEARCH;
               good_cnt <= 0;
               word_cnt := 0;
            end if;
         when SEARCH_RND_CLK =>
            -- toggle the random number generator for 1 clock
            next_state <= RECEIVE;
         when RECEIVE =>
            -- check each byte received to see if it's what we expect
            if (new_data = '1') then
               -- we've got new data - is it what we expect?
               if (lvds_dat = rnd_dat) then
                  -- yes, increment our good counter
                  good_cnt <= good_cnt + 1;
               else
                  -- no
                  good_cnt <= good_cnt;
               end if;
               next_state <= RECEIVE_RND_CLK;
               word_cnt := word_cnt + 1;
            else
               good_cnt <= good_cnt;
               word_cnt := word_cnt;
               next_state <= RECEIVE;
            end if;
         when RECEIVE_RND_CLK =>
            -- toggle the random number generator for 1 clock
            if (word_cnt = 255) then
               -- transmit result
               next_state <= TX_WRITE1;
            else
               -- keep going
               next_state <= RECEIVE;
            end if;
         when TX_WRITE1 =>
            -- transmit the high byte of the result and
            -- wait for an ack
            if (tx_ack_i = '1') then
               next_state <= TX_WAIT1;
            else
               next_state <= TX_WRITE1;
            end if;
         when TX_WAIT1 =>
            -- now wait for the transmitter to finish
            if ((tx_ack_i = '0') and (tx_busy_i = '0')) then
               next_state <= TX_WRITE2;
            else
               next_state <= TX_WAIT1;
            end if;
         when TX_WRITE2 =>
            -- transmit the high byte of the result and
            -- wait for an ack
            if (tx_ack_i = '1') then
               next_state <= TX_WAIT2;
            else
               next_state <= TX_WRITE2;
            end if;
         when TX_WAIT2 =>
            -- now wait for the transmitter to finish
            if ((tx_ack_i = '0') and (tx_busy_i = '0')) then
               next_state <= DONE;
            else
               next_state <= TX_WAIT2;
            end if;
         when DONE =>
            -- we never exit this state
            next_state <= DONE;
         when others =>
            next_state <= SEARCH;
      end case;
   end process state_logic;
   
   -- state_output controls all of the state outputs
   state_output : process (state)
      variable hex_reg : std_logic_vector(7 downto 0);
   begin
      case state is
         when SEARCH =>
            rnd_clr <= '1';
            rnd_clk <= '0';
            done_o <= '0';
            tx_we_o <= '0';
            tx_stb_o <= '0';
            hex_data <= "0000";
            hex_reg := "00000000";
         when SEARCH_RND_CLK =>
            rnd_clr <= '0';
            rnd_clk <= '1';
            done_o <= '0';
            tx_we_o <= '0';
            tx_stb_o <= '0';
            hex_data <= "0000";
            hex_reg := "00000000";
         when RECEIVE =>
            rnd_clr <= '0';
            rnd_clk <= '0';
            done_o <= '0';
            tx_we_o <= '0';
            tx_stb_o <= '0';
            hex_data <= "0000";
            hex_reg := "00000000";
         when RECEIVE_RND_CLK =>
            rnd_clr <= '0';
            rnd_clk <= '1';
            done_o <= '0';
            tx_we_o <= '0';
            tx_stb_o <= '0';
            hex_data <= "0000";
            hex_reg := "00000000";
         when TX_WRITE1 =>
            rnd_clr <= '0';
            rnd_clk <= '0';
            done_o <= '0';
            tx_we_o <= '1';
            tx_stb_o <= '1';
            hex_reg := conv_std_logic_vector(good_cnt, 8);
            hex_data <= hex_reg(7 downto 4);
         when TX_WAIT1 =>
            rnd_clr <= '0';
            rnd_clk <= '0';
            done_o <= '0';
            tx_we_o <= '0';
            tx_stb_o <= '0';
            hex_data <= hex_data;
            hex_reg := hex_reg;
         when TX_WRITE2 =>
            rnd_clr <= '0';
            rnd_clk <= '0';
            done_o <= '0';
            tx_we_o <= '1';
            tx_stb_o <= '1';
            hex_data <= hex_reg(3 downto 0);
            hex_reg := hex_reg;
         when TX_WAIT2 =>
            rnd_clr <= '0';
            rnd_clk <= '0';
            done_o <= '0';
            tx_we_o <= '0';
            tx_stb_o <= '0';
            hex_data <= hex_data;
            hex_reg := "00000000";
         when DONE =>
            rnd_clr <= '0';
            rnd_clk <= '0';
            done_o <= '1';
            tx_we_o <= '0';
            tx_stb_o <= '0';
            hex_data <= "0000";
            hex_reg := "00000000";
      end case;
   end process state_output;
end;
