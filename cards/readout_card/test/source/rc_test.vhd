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
-- rc_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri / Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test module for readout card
--
-- Revision history:
-- <date $Date: 2006/05/11 22:25:01 $>	- <initials $Author: bench2 $>
-- $Log: rc_test.vhd,v $
-- Revision 1.14  2006/05/11 22:25:01  bench2
-- modified error_msg, added 12.5MHz pll output, upgraded version number to 4.0
--
-- Revision 1.13  2005/11/19 00:36:21  erniel
-- updated RC_test to version 3.0
-- rewrote command interface logic (rc_test_idle, rc_test_reset are obsolete)
--
-- Revision 1.12  2004/07/19 20:19:19  mandana
-- added square wave test for parallel DACs
--
-- Revision 1.11  2004/07/17 00:00:00  mandana
-- adding SRAM test, v02 now
--
-- Revision 1.10  2004/07/16 18:56:32  mandana
-- adding SRAM test, v02 now
--
-- Revision 1.9  2004/07/16 00:16:37  bench1
-- Mandana: set the dac_test_mode for parallel dacs
--
-- Revision 1.8  2004/07/15 17:57:40  bench1
-- Mandana: corrected fix vs. ramp switch on dac tests
--
-- Revision 1.7  2004/07/15 00:38:26  bench1
-- Mandana: changed dac_sclk to dac_clk to match tcl file
--
-- Revision 1.6  2004/06/22 20:54:15  mandana
-- modified the output-port names to be consistent with tcl file
--
-- Revision 1.5  2004/06/22 17:42:40  mandana
-- added mode to port map and cleaned syntax errors
--
-- Revision 1.4  2004/06/21 22:42:25  mandana
-- Merging 1.2 and 1.3
--
-- Revision 1.3  2004/06/21 22:34:37  mandana
-- try merge
-- 
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library work;
use work.ascii_pack.all;

entity rc_test is
port(inclk : in std_logic;
     rst_n  : in std_logic;

     rx : in std_logic;
     tx : out std_logic;

     -- rc serial dac interface
     dac_dat        : out std_logic_vector (7 downto 0); 
     dac_clk       : out std_logic_vector (7 downto 0);
     bias_dac_ncs   : out std_logic_vector (7 downto 0); 
     offset_dac_ncs : out std_logic_vector (7 downto 0); 

     -- rc parallel dac interface
     dac_FB1_dat    : out std_logic_vector (13 downto 0);
     dac_FB2_dat    : out std_logic_vector (13 downto 0);
     dac_FB3_dat    : out std_logic_vector (13 downto 0);
     dac_FB4_dat    : out std_logic_vector (13 downto 0);
     dac_FB5_dat    : out std_logic_vector (13 downto 0);
     dac_FB6_dat    : out std_logic_vector (13 downto 0);
     dac_FB7_dat    : out std_logic_vector (13 downto 0);
     dac_FB8_dat    : out std_logic_vector (13 downto 0);
     dac_FB_clk   : out std_logic_vector (7 downto 0));     
      
     -- SRAM bank interface
--     sram_addr : out std_logic_vector(19 downto 0);
--     sram_data : inout std_logic_vector(15 downto 0);
--     sram_nbhe : out std_logic;
--     sram_nble : out std_logic;
--     sram_noe  : out std_logic;
--     sram_nwe  : out std_logic;
--     sram_ncs  : out std_logic);
end rc_test;

architecture rtl of rc_test is

constant RESET_MSG_LEN    : integer := 16;
constant IDLE_MSG_LEN     : integer := 10;
constant ERROR_MSG_LEN    : integer := 17;
constant EASTER_MSG_LEN   : integer := 24;

signal clk_4: std_logic;
signal clk : std_logic;
signal rst : std_logic;

component rc_test_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic);
end component;

type states is (RESET, TX_RESET, TX_IDLE, TX_ERROR, TX_EASTER, RX_CMD1, RX_CMD2, DAC_TEST_SETUP, WAIT_DAC_DONE);
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
signal easter_msg : std_logic_vector(7 downto 0);

signal cmd1    : std_logic_vector(7 downto 0);
signal cmd2    : std_logic_vector(7 downto 0);
signal cmd1_ld : std_logic;
signal cmd2_ld : std_logic;

signal rst_cmd : std_logic;

component rc_serial_dac_test_wrapper
port(rst_i     : in std_logic; 
     clk_i     : in std_logic; 
     clk_4_i   : in std_logic;
     en_i      : in std_logic; 
     mode      : in std_logic_vector(1 downto 0); 
     done_o    : out std_logic;
     dac_dat_o : out std_logic_vector (7 downto 0); 
     dac_ncs_o : out std_logic_vector (7 downto 0); 
     dac_clk_o : out std_logic_vector (7 downto 0)); 
end component;

signal serial_dac_ena : std_logic;
signal serial_dac_done : std_logic;
signal serial_dac_mode : std_logic_vector(1 downto 0);

signal dac_ncs : std_logic_vector(7 downto 0);

component rc_parallel_dac_test_wrapper
port(rst_i      : in std_logic;
     clk_i      : in std_logic;
     en_i       : in std_logic;
     mode       : in std_logic_vector(1 downto 0);
     done_o     : out std_logic;
     dac0_dat_o : out std_logic_vector(13 downto 0);
     dac1_dat_o : out std_logic_vector(13 downto 0);
     dac2_dat_o : out std_logic_vector(13 downto 0);
     dac3_dat_o : out std_logic_vector(13 downto 0);
     dac4_dat_o : out std_logic_vector(13 downto 0);
     dac5_dat_o : out std_logic_vector(13 downto 0);
     dac6_dat_o : out std_logic_vector(13 downto 0);
     dac7_dat_o : out std_logic_vector(13 downto 0);
     dac_clk_o  : out std_logic_vector(7 downto 0));   
end component;

signal parallel_dac_ena : std_logic;
signal parallel_dac_done : std_logic;
signal parallel_dac_mode : std_logic_vector(1 downto 0);

signal test_mode_ld : std_logic;

begin

   rst <= not rst_n or rst_cmd;

   clk0: rc_test_pll
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

   -- print out the version message
   with tx_count select              
      reset_msg <= newline   when 0,
                   newline   when 1,
                   shift(r)  when 2,
                   shift(c)  when 3,
                   space     when 4,
                   shift(t)  when 5,
                   e         when 6,
                   s         when 7,
                   t         when 8,
                   space     when 9,
                   v         when 10,
                   period    when 11, 
                   four      when 12, -- v4.1 test firmware
                   period    when 13,
                   one       when 14,
                   newline   when others;

   with tx_count select
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
      error_msg <= tab         when 0,
                   shift(i)    when 1,
                   n           when 2,
                   v           when 3,
                   a           when 4,
                   l           when 5,
                   i           when 6,
                   d           when 7,
                   space       when 8,
                   c           when 9,
                   o           when 10,
                   m           when 11,
                   m           when 12,
                   a           when 13,
                   n           when 14,
                   d           when 15,
                   space       when others;

   with tx_count select
      easter_msg <= n          when 0,
                    g          when 1,
                    i          when 2,
                    n          when 3,
                    e          when 4,
                    e          when 5,
                    r          when 6,
                    s          when 7,
                    space      when 8,
                    r          when 9,
                    u          when 10,
                    l          when 11,
                    e          when 12,
                    space      when 13,
                    t          when 14,
                    h          when 15,
                    e          when 16,
                    space      when 17,
                    w          when 18,
                    o          when 19,
                    r          when 20,
                    l          when 21,
                    d          when 22,
                    shift(one) when others;


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

   process(pres_state, rx_rdy, rx_data, tx_count, serial_dac_done, parallel_dac_done, cmd1)
   begin
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

         when TX_EASTER =>      if(tx_count = EASTER_MSG_LEN - 1) then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= TX_EASTER;
                                end if;

         when RX_CMD1 =>        if(rx_rdy = '1') then
                                   case rx_data is
                                      when e | shift(e) => next_state <= TX_EASTER;
                                      when p | shift(p) => next_state <= RX_CMD2;
                                      when s | shift(s) => next_state <= RX_CMD2;
                                      when escape =>       next_state <= RESET;
                                      when others =>       next_state <= TX_ERROR;
                                   end case;
                                else
                                   next_state <= RX_CMD1;
                                end if;

         when RX_CMD2 =>        if(rx_rdy = '1') then
                                   case rx_data is
                                      when f | shift(f) => next_state <= DAC_TEST_SETUP;
                                      when r | shift(r) => next_state <= DAC_TEST_SETUP;
                                      when s | shift(s) => if(cmd1 = p or cmd1 = shift(p)) then
                                                              next_state <= DAC_TEST_SETUP;
                                                           else
                                                              next_state <= TX_ERROR;
                                                           end if;
                                      when escape =>       next_state <= RESET;
                                      when others =>       next_state <= TX_ERROR;
                                   end case;
                                else
                                   next_state <= RX_CMD2;
                                end if;

         when DAC_TEST_SETUP => next_state <= WAIT_DAC_DONE;

         when WAIT_DAC_DONE =>  if(serial_dac_done = '1' or parallel_dac_done = '1') then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= WAIT_DAC_DONE;
                                end if;  

         when others =>         next_state <= TX_IDLE;

      end case;
   end process;

   process(pres_state, tx_busy, tx_count, reset_msg, idle_msg, error_msg, easter_msg, cmd1)
   begin
      rx_ack        <= '0';
      tx_rdy        <= '0';
      tx_data       <= (others => '0');
      tx_count_ena  <= '0';
      tx_count_clr  <= '0';
      cmd1_ld       <= '0';
      cmd2_ld       <= '0';
      test_mode_ld  <= '0';
      rst_cmd       <= '0';

      serial_dac_ena   <= '0';
      parallel_dac_ena <= '0';

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

         when TX_EASTER =>  if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = EASTER_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= easter_msg;

         when RX_CMD1 =>    rx_ack       <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            cmd1_ld      <= '1';

         when RX_CMD2 =>    rx_ack       <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            cmd2_ld      <= '1';

         when DAC_TEST_SETUP => test_mode_ld <= '1';

         when WAIT_DAC_DONE =>  if(cmd1 = p or cmd1 = shift(p)) then
                                   parallel_dac_ena <= '1';
                                elsif(cmd1 = s or cmd1 = shift(s)) then
                                   serial_dac_ena <= '1';
                                end if;

         when others =>     null;

      end case;
   end process;
           

   --------------------------------------------------------
   -- DAC Test Mode register
   --------------------------------------------------------

   process(clk, rst)
   begin
      if(rst = '1') then
         parallel_dac_mode <= (others => '0');
         serial_dac_mode <= (others => '0');
      elsif(clk'event and clk = '1') then
         if(test_mode_ld = '1') then
            if(cmd1 = p or cmd1 = shift(p)) then
               if(cmd2 = f or cmd2 = shift(f)) then
                  parallel_dac_mode <= "00";
               elsif(cmd2 = r or cmd2 = shift(r)) then
                  parallel_dac_mode <= "01";
               elsif(cmd2 = s or cmd2 = shift(s)) then
                  parallel_dac_mode <= "10";
               end if;
            elsif(cmd1 = s or cmd1 = shift(s)) then
               if(cmd2 = f or cmd2 = shift(f)) then
                  serial_dac_mode <= "00";
               elsif(cmd2 = r or cmd2 = shift(r)) then
                  serial_dac_mode <= "01";
               end if;
            end if;
         end if;
      end if;
   end process;


   --------------------------------------------------------
   -- Serial DAC block
   --------------------------------------------------------
               
   rc_serial_dac : rc_serial_dac_test_wrapper
      port map(rst_i     => rst,
               clk_i     => clk,
               clk_4_i   => clk_4,
               en_i      => serial_dac_ena,
               mode      => serial_dac_mode,
               done_o    => serial_dac_done,

               dac_clk_o => dac_clk,
               dac_dat_o => dac_dat,
               dac_ncs_o => dac_ncs);

   bias_dac_ncs <= (others=> '1');
   offset_dac_ncs <= dac_ncs;

   --------------------------------------------------------
   -- Parallel DAC block
   --------------------------------------------------------

   rc_parallel_dac : rc_parallel_dac_test_wrapper
      port map(rst_i       => rst,
               clk_i       => clk,
               en_i        => parallel_dac_ena,
               mode        => parallel_dac_mode,               
               done_o      => parallel_dac_done,
               
               dac0_dat_o  => dac_FB1_dat,
               dac1_dat_o  => dac_FB2_dat,
               dac2_dat_o  => dac_FB3_dat,
               dac3_dat_o  => dac_FB4_dat,
               dac4_dat_o  => dac_FB5_dat,
               dac5_dat_o  => dac_FB6_dat,
               dac6_dat_o  => dac_FB7_dat,
               dac7_dat_o  => dac_FB8_dat,
               dac_clk_o   => dac_FB_clk);

end rtl;