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
-- ac_test.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test module for common items
--
-- Revision history:
-- <date $Date: 2006/08/02 22:43:15 $>	- <initials $Author: mandana $>
-- $Log: ac_test.vhd,v $
-- Revision 1.10  2006/08/02 22:43:15  mandana
-- updated revision to 3.0
-- added ramp_off_msg to not let the user know to turn off the ramp mode before applying fixed values
-- removed easter_msg
-- updated error_msg to be more informative
-- added pll output for ramp_test 12.5MHz clock
-- fixed the bug associated with typing f while ramp mode was enabled
--
-- Revision 1.9  2005/11/22 00:01:19  erniel
-- updated AC_test to version 2.0b:
--      minor bug fix to ac_dac_ctrl_test
--
-- Revision 1.8  2005/11/21 20:05:00  erniel
-- updated AC_test to version 2.0
-- rewrote command interface logic (ac_test_idle, ac_test_reset are obsolete)
--
-- Revision 1.7  2004/06/25 19:39:50  erniel
-- Bryce: updated the pll reference
--
-- Revision 1.6  2004/05/25 23:29:33  erniel
-- synthesized, ramp and fixed value test debugged
--
-- Revision 1.5  2004/05/17 19:09:34  erniel
-- expanded dac_dat_o into 11 separate 14-bit vectors
--
-- Revision 1.4  2004/05/17 00:51:13  erniel
-- added LVDS tx a & b modules
-- removed LVDS rx clock module
-- removed redundant test modules
--
-- Revision 1.3  2004/05/13 17:44:06  mandana
-- modified all_test for ac_test
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library work;
use work.ascii_pack.all;

entity ac_test is
port(inclk : in std_logic;
     rst_n  : in std_logic;

     rx : in std_logic;
     tx : out std_logic;

     dac_data0  : out std_logic_vector(13 downto 0);
     dac_data1  : out std_logic_vector(13 downto 0);
     dac_data2  : out std_logic_vector(13 downto 0);
     dac_data3  : out std_logic_vector(13 downto 0);
     dac_data4  : out std_logic_vector(13 downto 0);
     dac_data5  : out std_logic_vector(13 downto 0);
     dac_data6  : out std_logic_vector(13 downto 0);
     dac_data7  : out std_logic_vector(13 downto 0);
     dac_data8  : out std_logic_vector(13 downto 0);
     dac_data9  : out std_logic_vector(13 downto 0);
     dac_data10 : out std_logic_vector(13 downto 0);
     dac_clk    : out std_logic_vector(40 downto 0));
end ac_test;

architecture rtl of ac_test is

constant RESET_MSG_LEN    : integer := 16;
constant IDLE_MSG_LEN     : integer := 10;
constant ERROR_MSG_LEN    : integer := 8;  
constant RAMP_OFF_MSG_LEN : integer := 22;

signal clk  : std_logic;
signal clk_4: std_logic;
signal rst  : std_logic;

component ac_test_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic);
end component;

type states is (RESET, TX_RESET, TX_IDLE, TX_ERROR, RX_CMD1, RX_CMD2, FIXED_DAC_TEST, RAMP_OFF_MSG, RAMP_DAC_TEST, WAIT_DAC_DONE);
signal pres_state : states;
signal next_state : states;

component rs232_tx
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     dat_i   : in std_logic_vector(7 downto 0);
     rdy_i   : in std_logic;
     busy_o  : out std_logic;
     rs232_o : out std_logic);
end component;

signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy  : std_logic;
signal tx_busy : std_logic;

component rs232_rx
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     dat_o   : out std_logic_vector(7 downto 0);
     rdy_o   : out std_logic;
     ack_i   : in std_logic;
     rs232_i : in std_logic);
end component;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_ack  : std_logic;
signal rx_rdy  : std_logic;

signal tx_count : integer range 0 to 70;
signal tx_count_ena : std_logic;
signal tx_count_clr : std_logic;

signal reset_msg  : std_logic_vector(7 downto 0);
signal idle_msg   : std_logic_vector(7 downto 0);
signal error_msg  : std_logic_vector(7 downto 0);
signal ramp_msg   : std_logic_vector(7 downto 0);

signal cmd1    : std_logic_vector(7 downto 0);
signal cmd2    : std_logic_vector(7 downto 0);
signal cmd1_ld : std_logic;
signal cmd2_ld : std_logic;

signal rst_cmd : std_logic;

component ac_dac_ctrl_test
port(rst_i       : in std_logic;
     clk_i       : in std_logic;
     en_i        : in std_logic;
     done_o      : out std_logic;
     dac_dat0_o  : out std_logic_vector(13 downto 0);
     dac_dat1_o  : out std_logic_vector(13 downto 0);
     dac_dat2_o  : out std_logic_vector(13 downto 0);
     dac_dat3_o  : out std_logic_vector(13 downto 0);
     dac_dat4_o  : out std_logic_vector(13 downto 0);
     dac_dat5_o  : out std_logic_vector(13 downto 0);
     dac_dat6_o  : out std_logic_vector(13 downto 0);
     dac_dat7_o  : out std_logic_vector(13 downto 0);
     dac_dat8_o  : out std_logic_vector(13 downto 0);
     dac_dat9_o  : out std_logic_vector(13 downto 0);
     dac_dat10_o : out std_logic_vector(13 downto 0);
     dac_clk_o   : out std_logic_vector (40 downto 0));
end component;

signal fixed_dac_ena  : std_logic;
signal fixed_dac_done : std_logic;
signal fix_dac_data0  : std_logic_vector(13 downto 0);
signal fix_dac_data1  : std_logic_vector(13 downto 0);
signal fix_dac_data2  : std_logic_vector(13 downto 0);
signal fix_dac_data3  : std_logic_vector(13 downto 0);
signal fix_dac_data4  : std_logic_vector(13 downto 0);
signal fix_dac_data5  : std_logic_vector(13 downto 0);
signal fix_dac_data6  : std_logic_vector(13 downto 0);
signal fix_dac_data7  : std_logic_vector(13 downto 0);
signal fix_dac_data8  : std_logic_vector(13 downto 0);
signal fix_dac_data9  : std_logic_vector(13 downto 0);
signal fix_dac_data10 : std_logic_vector(13 downto 0);
signal fix_dac_clk    : std_logic_vector(40 downto 0);


component ac_dac_ramp
port(rst_i       : in std_logic;
     clk_i       : in std_logic;
     clk_4_i     : in std_logic;
     en_i        : in std_logic;
     done_o      : out std_logic;
     dac_dat0_o  : out std_logic_vector(13 downto 0);
     dac_dat1_o  : out std_logic_vector(13 downto 0);
     dac_dat2_o  : out std_logic_vector(13 downto 0);
     dac_dat3_o  : out std_logic_vector(13 downto 0);
     dac_dat4_o  : out std_logic_vector(13 downto 0);
     dac_dat5_o  : out std_logic_vector(13 downto 0);
     dac_dat6_o  : out std_logic_vector(13 downto 0);
     dac_dat7_o  : out std_logic_vector(13 downto 0);
     dac_dat8_o  : out std_logic_vector(13 downto 0);
     dac_dat9_o  : out std_logic_vector(13 downto 0);
     dac_dat10_o : out std_logic_vector(13 downto 0);
     dac_clk_o   : out std_logic_vector(40 downto 0));
end component;

signal ramp_dac_ena    : std_logic;
signal ramp_dac_done   : std_logic;
signal ramp_dac_data0  : std_logic_vector(13 downto 0);
signal ramp_dac_data1  : std_logic_vector(13 downto 0);
signal ramp_dac_data2  : std_logic_vector(13 downto 0);
signal ramp_dac_data3  : std_logic_vector(13 downto 0);
signal ramp_dac_data4  : std_logic_vector(13 downto 0);
signal ramp_dac_data5  : std_logic_vector(13 downto 0);
signal ramp_dac_data6  : std_logic_vector(13 downto 0);
signal ramp_dac_data7  : std_logic_vector(13 downto 0);
signal ramp_dac_data8  : std_logic_vector(13 downto 0);
signal ramp_dac_data9  : std_logic_vector(13 downto 0);
signal ramp_dac_data10 : std_logic_vector(13 downto 0);
signal ramp_dac_clk    : std_logic_vector(40 downto 0);

signal ramp_enabled : std_logic;

begin

   rst <= not rst_n or rst_cmd;

   clk0: ac_test_pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => clk_4);


   --------------------------------------------------------
   -- RS-232 blocks
   --------------------------------------------------------

   rx0: rs232_rx
   port map(clk_i   => clk,
            rst_i   => rst,
            dat_o   => rx_data,
            rdy_o   => rx_rdy,
            ack_i   => rx_ack,
            rs232_i => rx);

   tx0: rs232_tx
   port map(clk_i   => clk,
            rst_i   => rst,
            dat_i   => tx_data,
            rdy_i   => tx_rdy,
            busy_o  => tx_busy,
            rs232_o => tx);


   --------------------------------------------------------
   -- Command character storage
   --------------------------------------------------------

   cmdchar1 : reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => cmd1_ld,
            reg_i  => rx_data,
            reg_o  => cmd1);

   cmdchar2 : reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => cmd2_ld,
            reg_i  => rx_data,
            reg_o  => cmd2);


   --------------------------------------------------------
   -- Message logic
   --------------------------------------------------------

   tx_char_counter: counter
   generic map(MAX => 70,
               WRAP_AROUND => '0')
   port map(clk_i   => clk,
            rst_i   => rst,
            ena_i   => tx_count_ena,
            load_i  => tx_count_clr,
            count_i => 0,
            count_o => tx_count);

   
   with tx_count select 
      -- reset message is AC Test v3.0
      reset_msg <= newline   when 0,
                   newline   when 1,
                   shift(a)  when 2,
                   shift(c)  when 3,
                   space     when 4,
                   shift(t)  when 5,
                   e         when 6,
                   s         when 7,
                   t         when 8,
                   space     when 9,
                   v         when 10,
                   period    when 11, 
                   three     when 12, 
                   period    when 13,
                   zero      when 14,
                   newline   when others;

   with tx_count select
      -- idle message is Command? 
      idle_msg <= newline      when 0,
                  shift(c)     when 1,
                  o            when 2,
                  m            when 3,
                  m            when 4,
                  a            when 5,
                  n            when 6,
                  d            when 7,
                  shift(slash) when 8,
                  space        when others;

   with tx_count select
      -- error message is error 
      error_msg <= tab         when 0,
                   e           when 1,
                   r           when 2,
                   r           when 3,
                   o           when 4,
                   r           when 5,
                   space       when 6,
                   newline  when others;

   with tx_count select
      -- ramp_off message is turn off ramp first! 
      ramp_msg  <= tab         when 0,
                   t           when 1,
                   u           when 2,
                   r           when 3,
                   n           when 4,
                   space       when 5,
                   o           when 6,
                   f           when 7,
                   f           when 8,
                   space       when 9,
                   r           when 10,  
                   a 	       when 11,
                   m	       when 12,
                   p	       when 13,
                   space       when 14,
                   f	       when 15,
                   i	       when 16,
                   r	       when 17,
                   s	       when 18,
                   t	       when 19,
                   shift(one)  when 20,                   
                   newline  when others;

   --------------------------------------------------------
   -- Control logic
   --------------------------------------------------------

   process(clk, rst_n)
   begin
      if(rst_n = '0') then
         pres_state <= RESET;
      elsif(clk = '1' and clk'event) then
         pres_state <= next_state;
      end if;
   end process;

   process(pres_state, rx_rdy, rx_data, tx_count, fixed_dac_done, ramp_dac_done)
   begin
      next_state <= pres_state;

      case pres_state is
         when RESET =>          next_state <= TX_RESET;

         when TX_RESET =>       if(tx_count = RESET_MSG_LEN - 1) then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= TX_RESET;
                                end if;

         when TX_IDLE =>        if(tx_count = IDLE_MSG_LEN - 1) then
                                   next_state <= RX_CMD1;
                                else
                                   next_state <= TX_IDLE;
                                end if;

         when TX_ERROR =>       if(tx_count = ERROR_MSG_LEN - 1) then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= TX_ERROR;
                                end if;

         when RX_CMD1 =>        if(rx_rdy = '1') then
                                   case rx_data is
                                      when f | shift(f) => next_state <= FIXED_DAC_TEST;
                                      when r | shift(r) => next_state <= RAMP_DAC_TEST;
                                      when escape =>       next_state <= RESET;
                                      when others =>       next_state <= TX_ERROR;
                                   end case;
                                else
                                   next_state <= RX_CMD1;
                                end if;

         when FIXED_DAC_TEST => if(ramp_enabled = '0') then
                                  next_state <= WAIT_DAC_DONE;
                                else
                                  next_state <= RAMP_OFF_MSG;
                                end if;
         
         when RAMP_OFF_MSG  =>  if(tx_count = RAMP_OFF_MSG_LEN - 1) then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= RAMP_OFF_MSG;
                                end if;                     

         when RAMP_DAC_TEST =>  next_state <= WAIT_DAC_DONE;

         when WAIT_DAC_DONE =>  if(fixed_dac_done = '1' or ramp_dac_done = '1') then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= WAIT_DAC_DONE;
                                end if;

         when others =>         next_state <= TX_IDLE;

      end case;
   end process;

   process(pres_state, tx_busy, tx_count, reset_msg, idle_msg, error_msg, ramp_enabled)
   begin
      rx_ack        <= '0';
      tx_rdy        <= '0';
      tx_data       <= (others => '0');
      tx_count_ena  <= '0';
      tx_count_clr  <= '0';
      cmd1_ld       <= '0';
      cmd2_ld       <= '0';

      rst_cmd       <= '0';
      fixed_dac_ena <= '0';
      ramp_dac_ena  <= '0';

      case pres_state is
         when RESET =>      tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            rst_cmd      <= '1';

         when TX_RESET =>   if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = RESET_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= reset_msg;

         when TX_IDLE =>    if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = IDLE_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= idle_msg;

         when TX_ERROR =>   if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = ERROR_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= error_msg;

         when RX_CMD1 =>    rx_ack       <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            cmd1_ld      <= '1';

         when FIXED_DAC_TEST => if(ramp_enabled = '0') then   -- only turn on fixed dac when ramp is off
                                   fixed_dac_ena <= '1';
                                end if;
         when RAMP_OFF_MSG  => 
                            if (tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = RAMP_OFF_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;   
                            tx_data <= ramp_msg;

         when RAMP_DAC_TEST =>  ramp_dac_ena <= '1';

         when others =>     null;

      end case;
   end process;

   --------------------------------------------------------
   -- DAC (Fixed Mode) block
   --------------------------------------------------------

   ac_dac_fix : ac_dac_ctrl_test
      port map(rst_i       => rst,
               clk_i       => clk,
               en_i        => fixed_dac_ena,
               done_o      => fixed_dac_done,

               dac_dat0_o  => fix_dac_data0,
               dac_dat1_o  => fix_dac_data1,
               dac_dat2_o  => fix_dac_data2,
               dac_dat3_o  => fix_dac_data3,
               dac_dat4_o  => fix_dac_data4,
               dac_dat5_o  => fix_dac_data5,
               dac_dat6_o  => fix_dac_data6,
               dac_dat7_o  => fix_dac_data7,
               dac_dat8_o  => fix_dac_data8,
               dac_dat9_o  => fix_dac_data9,
               dac_dat10_o => fix_dac_data10,
               dac_clk_o   => fix_dac_clk);


   --------------------------------------------------------
   -- DAC (Ramp Mode) Block
   --------------------------------------------------------

   ac_dac_ramp1 : ac_dac_ramp
      port map(rst_i       => rst,
               clk_i       => clk,
               clk_4_i     => clk_4,
               en_i        => ramp_dac_ena,
               done_o      => ramp_dac_done,

               dac_dat0_o  => ramp_dac_data0,
               dac_dat1_o  => ramp_dac_data1,
               dac_dat2_o  => ramp_dac_data2,
               dac_dat3_o  => ramp_dac_data3,
               dac_dat4_o  => ramp_dac_data4,
               dac_dat5_o  => ramp_dac_data5,
               dac_dat6_o  => ramp_dac_data6,
               dac_dat7_o  => ramp_dac_data7,
               dac_dat8_o  => ramp_dac_data8,
               dac_dat9_o  => ramp_dac_data9,
               dac_dat10_o => ramp_dac_data10,
               dac_clk_o   => ramp_dac_clk);


   -- This process keeps track of whether ramp mode is currently enabled or not:
   process(clk, rst)
   begin
      if(rst = '1') then
         ramp_enabled <= '0';
      elsif(clk'event and clk = '1') then
         if(ramp_dac_ena = '1') then
            ramp_enabled <= not ramp_enabled;
         end if;
      end if;
   end process;

   -- Multiplexing fixed mode and ramp mode DAC test wrapper outputs:
   dac_data0  <= ramp_dac_data0  when ramp_enabled = '1' else fix_dac_data0;
   dac_data1  <= ramp_dac_data1  when ramp_enabled = '1' else fix_dac_data1;
   dac_data2  <= ramp_dac_data2  when ramp_enabled = '1' else fix_dac_data2;
   dac_data3  <= ramp_dac_data3  when ramp_enabled = '1' else fix_dac_data3;
   dac_data4  <= ramp_dac_data4  when ramp_enabled = '1' else fix_dac_data4;
   dac_data5  <= ramp_dac_data5  when ramp_enabled = '1' else fix_dac_data5;
   dac_data6  <= ramp_dac_data6  when ramp_enabled = '1' else fix_dac_data6;
   dac_data7  <= ramp_dac_data7  when ramp_enabled = '1' else fix_dac_data7;
   dac_data8  <= ramp_dac_data8  when ramp_enabled = '1' else fix_dac_data8;
   dac_data9  <= ramp_dac_data9  when ramp_enabled = '1' else fix_dac_data9;
   dac_data10 <= ramp_dac_data10 when ramp_enabled = '1' else fix_dac_data10;
   dac_clk    <= ramp_dac_clk    when ramp_enabled = '1' else fix_dac_clk;

end rtl;