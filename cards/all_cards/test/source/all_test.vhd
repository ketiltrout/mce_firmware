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
-- all_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test module for common items
--
-- Revision history:
-- 
-- $Log: all_test.vhd,v $
-- Revision 1.1  2004/04/28 20:16:13  erniel
-- initial version
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.async_pack.all;
use work.all_test_pack.all;

entity all_test is
   port(
      reset_n : in std_logic;
      inclk : in std_logic;
      outclk : out std_logic;
      txd : out std_logic;
      rxd : in std_logic;
      
      -- dip interface
      dip : in std_logic_vector(7 downto 0);
      
      -- led interface
      led : out std_logic_vector(2 downto 0);
      
      -- watchdog timer interface                      
      wdt : out std_logic;
      
      -- LVDS transmit interface
      sync : out std_logic;
      cmd : out std_logic;
      spare : out std_logic;
      
      -- slot id interface
      slot_id : in std_logic_vector (3 downto 0);
      
      -- array id interface
      array_id : in std_logic_vector (2 downto 0);
      
      -- card id interface
      card_id : inout std_logic);
      
      -- box id interface
--      box_id : inout std_logic);
end all_test;

architecture behaviour of all_test is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        e0 : out std_logic);
   end component;

   constant MAX_STATES : integer := 12;
   signal zero : std_logic;
   signal one : std_logic;
   signal reset : std_logic;
   signal int_reset : std_logic;
   signal clk : std_logic;

   -- transmitter signals
   signal tx_clock : std_logic;
   signal tx_busy  : std_logic;
   signal tx_ack   : std_logic;
   signal tx_data  : std_logic_vector(7 downto 0);
   signal tx_we    : std_logic;
   signal tx_stb   : std_logic;
   
   -- reciever signals
   signal rx_clock : std_logic;
   signal rx_valid : std_logic;
   signal rx_error : std_logic;
   signal rx_read  : std_logic;
   signal rx_data  : std_logic_vector(7 downto 0);
   signal rx_stb   : std_logic;
   signal rx_ack   : std_logic;
   
   -- state signals
   type cmd_states is (CMD_RESET, CMD_WAIT, CMD_DECODE, CMD_EXECUTE);
   signal cmd_state : cmd_states;
   
   signal sel_vec : std_logic_vector(MAX_STATES - 1 downto 0);
   signal done_vec : std_logic_vector(MAX_STATES - 1 downto 0);
   
   signal cmd1 : std_logic_vector(7 downto 0);
   signal cmd2 : std_logic_vector(7 downto 0);
   
   -- state constants
   constant INDEX_RESET         : integer := 0;
   constant INDEX_IDLE          : integer := 1;
   constant INDEX_LED_POWER     : integer := 2;
   constant INDEX_LED_STATUS    : integer := 3;
   constant INDEX_LED_FAULT     : integer := 4;
   constant INDEX_WATCHDOG      : integer := 5;
   constant INDEX_LVDS_TX_CMD   : integer := 6;
   constant INDEX_LVDS_TX_SYNC  : integer := 7;
   constant INDEX_LVDS_TX_SPARE : integer := 8;
   constant INDEX_SLOT_ID       : integer := 9;
   constant INDEX_CARD_ID       : integer := 10;
   constant INDEX_ARRAY_ID      : integer := 11;
   
   constant SEL_RESET          : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant SEL_IDLE           : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant SEL_LED_POWER      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_POWER => '1', others => '0');
   constant SEL_LED_STATUS     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_STATUS => '1', others => '0');
   constant SEL_LED_FAULT      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_FAULT => '1', others => '0');
   constant SEL_WATCHDOG       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_WATCHDOG => '1', others => '0');
   constant SEL_LVDS_TX_CMD    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_CMD => '1', others => '0');
   constant SEL_LVDS_TX_SYNC   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_SYNC => '1', others => '0');
   constant SEL_LVDS_TX_SPARE  : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_SPARE => '1', others => '0');
   constant SEL_SLOT_ID        : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SLOT_ID => '1', others => '0');
   constant SEL_CARD_ID        : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_CARD_ID => '1', others => '0');
   constant SEL_ARRAY_ID       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_ARRAY_ID => '1', others => '0');
   
   constant DONE_NULL          : std_logic_vector(MAX_STATES - 1 downto 0) := (others => '0');
   constant DONE_RESET         : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant DONE_IDLE          : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant DONE_LED_POWER     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_POWER => '1', others => '0');
   constant DONE_LED_STATUS    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_STATUS => '1', others => '0');
   constant DONE_LED_FAULT     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_FAULT => '1', others => '0');
   constant DONE_WATCHDOG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_WATCHDOG => '1', others => '0');
   constant DONE_LVDS_TX_CMD   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_CMD => '1', others => '0');
   constant DONE_LVDS_TX_SYNC  : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_SYNC => '1', others => '0');
   constant DONE_LVDS_TX_SPARE : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_SPARE => '1', others => '0');
   constant DONE_SLOT_ID       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SLOT_ID => '1', others => '0');
   constant DONE_CARD_ID       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_CARD_ID => '1', others => '0');
   constant DONE_ARRAY_ID      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_ARRAY_ID => '1', others => '0');

   -- device return signals:
   signal reset_data    : std_logic_vector(7 downto 0);
   signal idle_data     : std_logic_vector(7 downto 0);
   signal slot_id_data  : std_logic_vector(7 downto 0);
   signal card_id_data  : std_logic_vector(7 downto 0);
   signal array_id_data : std_logic_vector(7 downto 0);
   
   signal reset_we      : std_logic;
   signal idle_we       : std_logic;
   signal slot_id_we    : std_logic;
   signal card_id_we    : std_logic;
   signal array_id_we   : std_logic;
   
   signal reset_stb     : std_logic;
   signal idle_stb      : std_logic;
   signal slot_id_stb   : std_logic;
   signal card_id_stb   : std_logic;
   signal array_id_stb  : std_logic;
   
begin
   clk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               e0 => outclk);

   -- RS232 interface start
   receiver : async_rx
      port map(rx_i => rxd,
               flag_o => rx_valid,
               error_o => rx_error,
               clk_i => rx_clock,
               rst_i => reset,
               dat_o => rx_data,
               we_i => zero,
               stb_i => rx_stb,
               ack_o => rx_ack,
               cyc_i => one);

   transmitter : async_tx
      port map(tx_o => txd,
               busy_o => tx_busy,
               clk_i => tx_clock,
               rst_i => reset,
               dat_i => tx_data,
               we_i => tx_we,
               stb_i => tx_stb,
               ack_o => tx_ack,
               cyc_i => one);
   
   aclock : async_clk
      port map(clk_i => clk,
               rst_i => reset,
               txclk_o => tx_clock,
               rxclk_o => rx_clock);
      
   -- RS232 interface end
   
   -- reset_state gives us our welcome string on startup
   reset_state : all_test_reset
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_RESET),
               done_o    => done_vec(INDEX_RESET),
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => reset_data,
               tx_we_o   => reset_we,
               tx_stb_o  => reset_stb);
   
   -- idle_state is special - it aquires commands for us to process
   idle_state : all_test_idle
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_IDLE),
               done_o    => done_vec(INDEX_IDLE),
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => idle_data,
               tx_we_o   => idle_we,
               tx_stb_o  => idle_stb,
               
               rx_valid_i => rx_valid,
               rx_ack_i  => rx_ack,
               rx_stb_o  => rx_stb,
               rx_data_i => rx_data,
               
               cmd1_o => cmd1,
               cmd2_o => cmd2);
      
   -- power led
   led_power : led_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_LED_POWER),
               done_o    => done_vec(INDEX_LED_POWER),
               led_o     => led(0));
   
   -- status led
   led_status : led_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_LED_STATUS),
               done_o    => done_vec(INDEX_LED_STATUS),
               led_o     => led(1));
   
   -- fault led
   led_fault : led_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_LED_FAULT),
               done_o    => done_vec(INDEX_LED_FAULT),
               led_o     => led(2));
      
   -- watchdog timer
   watchdog_timer : watchdog_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_WATCHDOG),
               done_o    => done_vec(INDEX_WATCHDOG),
               wdt_o     => wdt);
         
   -- LVDS CMD transmitter
   lvds_cmd : lvds_tx_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_LVDS_TX_CMD),
               done_o    => done_vec(INDEX_LVDS_TX_CMD),
               lvds_o    => cmd);
   
   -- LVDS SYNC transmitter
   lvds_sync : lvds_tx_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_LVDS_TX_SYNC),
               done_o    => done_vec(INDEX_LVDS_TX_SYNC),
               lvds_o    => sync);

   -- LVDS SPARE transmitter
   lvds_spare : lvds_tx_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_LVDS_TX_SPARE),
               done_o    => done_vec(INDEX_LVDS_TX_SPARE), 
               lvds_o    => spare);

   slotid : slot_id_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_SLOT_ID),
               done_o    => done_vec(INDEX_SLOT_ID),
               slot_id_i => slot_id,
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => slot_id_data,
               tx_we_o   => slot_id_we,
               tx_stb_o  => slot_id_stb);
               
   cardid : card_id_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_CARD_ID),
               done_o    => done_vec(INDEX_CARD_ID),
               data_bi   => card_id,
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => card_id_data,
               tx_we_o   => card_id_we,
               tx_stb_o  => card_id_stb);
               
   arrayid : array_id_test_wrapper
      port map(rst_i     => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_ARRAY_ID),
               done_o    => done_vec(INDEX_ARRAY_ID),
               array_id_i => array_id,
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => array_id_data,
               tx_we_o   => array_id_we,
               tx_stb_o  => array_id_stb);
      
      
   zero <= '0';
   one <= '1';                         
   reset <= not reset_n or int_reset;
   
   -- functionality of async_mux:
   
   with sel_vec select
      tx_data <= reset_data    when SEL_RESET,
                 idle_data     when SEL_IDLE,
                 slot_id_data  when SEL_SLOT_ID,
                 card_id_data  when SEL_CARD_ID,
                 array_id_data when SEL_ARRAY_ID,
                 "00000000"    when others;
   
   with sel_vec select
      tx_we   <= reset_we      when SEL_RESET,
                 idle_we       when SEL_IDLE,
                 slot_id_we    when SEL_SLOT_ID,
                 card_id_we    when SEL_CARD_ID,
                 array_id_we   when SEL_ARRAY_ID,
                 '0'           when others; 
   
   with sel_vec select
      tx_stb  <= reset_stb     when SEL_RESET,
                 idle_stb      when SEL_IDLE,
                 slot_id_stb   when SEL_SLOT_ID,
                 card_id_stb   when SEL_CARD_ID,
                 array_id_stb  when SEL_ARRAY_ID,
                 '0'           when others;
   
   -- cmd_proc is our main processing state machine
   cmd_proc : process (reset, clk)
   begin
      if (reset = '1') then
         int_reset <= '0';
         sel_vec <= SEL_RESET;
         cmd_state <= CMD_RESET;
      elsif Rising_Edge(clk) then
         case cmd_state is
            when CMD_RESET => 
               -- wait for the reset state to complete
               if (done_vec = DONE_RESET) then
                  cmd_state <= CMD_WAIT;
               else
                  cmd_state <= cmd_state;
               end if;
               sel_vec <= SEL_RESET;
               
            when CMD_WAIT =>
               -- wait for a command to be decoded
               if (done_vec = DONE_IDLE) then
                  cmd_state <= CMD_DECODE;
               else
                  cmd_state <= cmd_state;
               end if;
               sel_vec <= SEL_IDLE;
               
            when CMD_DECODE =>
               -- activate the appropiate test module
               cmd_state <= CMD_EXECUTE;
               if(cmd1 = CMD_LED) then
                     -- toggle a LED
                     if (cmd2 = CMD_LED_1) then
                        sel_vec <= SEL_LED_POWER;
                     elsif (cmd2 = CMD_LED_2) then
                        sel_vec <= SEL_LED_STATUS;
                     else
                        sel_vec <= SEL_LED_FAULT;
                     end if;
                     
               elsif(cmd1 = CMD_WATCHDOG) then
                     -- kick watchdog
                     sel_vec <= SEL_WATCHDOG;

               elsif(cmd1 = CMD_TX) then
                     -- random number tx test
                     if (cmd2 = CMD_TX_0) then
                        sel_vec <= SEL_LVDS_TX_CMD;
                     elsif (cmd2 = CMD_TX_1) then
                        sel_vec <= SEL_LVDS_TX_SYNC;
                     else
                        sel_vec <= SEL_LVDS_TX_SPARE;
                     end if;
                  
               elsif(cmd1 = CMD_ID) then
                     if(cmd2 = CMD_ID_SLOT) then
                        sel_vec <= SEL_SLOT_ID;
                     elsif(cmd2 = CMD_ID_ARRAY) then
                        sel_vec <= SEL_ARRAY_ID;
                     elsif(cmd2 = CMD_ID_SERIAL) then
                        sel_vec <= SEL_CARD_ID;
                     end if;

               elsif(cmd1 = CMD_RESET) then
                  int_reset <= '1';

               else
                  -- must not be implemented yet!
                  sel_vec <= (others => '0');
                  cmd_state <= CMD_WAIT;
               end if;
               
            when CMD_EXECUTE =>
               -- wait for thet test to complete
               if (done_vec /= DONE_NULL) then
                  int_reset <= '0';
                  sel_vec <= (others => '0');
                  cmd_state <= CMD_WAIT;
               end if;
               
            when others =>
               sel_vec <= (others => '0');
               cmd_state <= CMD_RESET;
         end case;
      end if;
   end process cmd_proc;
end behaviour;
