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
-- Revision 1.5  2004/06/29 22:24:56  erniel
-- uses new rs232 interface
-- reset state enabled only
--
-- Revision 1.4  2004/05/17 00:57:04  erniel
-- removed LVDS test modules
--
-- Revision 1.3  2004/05/11 03:24:11  erniel
-- added LVDS rx test wrappers
-- added dip switch test wrapper
-- changed state machine state names
-- added rs232_data_tx sanity test
--
-- Revision 1.2  2004/05/03 02:38:05  erniel
-- implemented reset command
--
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
      n_rst : in std_logic;
      
      -- clock signals
      inclk : in std_logic;
      outclk : out std_logic;
      
      -- RS232 debug interface
      debug_tx : out std_logic;
      debug_rx : in std_logic;
      
      test : out std_logic_vector(38 downto 11);

      -- led interface
      grn_led : out std_logic;
      ylw_led : out std_logic;
      red_led : out std_logic;
            
      -- dip switch interface
      dip_sw3 : in std_logic;
      dip_sw4 : in std_logic;
      
      -- watchdog timer interface                      
      wdog : out std_logic;
      
      -- id interfaces
      slot_id : in std_logic_vector (3 downto 0);
      card_id : inout std_logic);
end all_test;

architecture behaviour of all_test is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        c1 : out std_logic;
        e0 : out std_logic);
   end component;

   
   signal zero : std_logic;
   signal one : std_logic;
   
   signal clk : std_logic; 
   signal comm_clk : std_logic;
     
   signal rst : std_logic;
   signal int_rst : std_logic;
   
   signal dip : std_logic_vector(1 downto 0);

   -- transmitter signals
   signal tx_data  : std_logic_vector(7 downto 0);
   signal tx_start : std_logic;
   signal tx_done  : std_logic;
     
--   signal tx_clock : std_logic;
--   signal tx_busy  : std_logic;
--   signal tx_ack   : std_logic;
--   signal tx_data  : std_logic_vector(7 downto 0);
--   signal tx_start    : std_logic;
--   signal tx_stb   : std_logic;
   
   -- reciever signals
   signal rx_data  : std_logic_vector(7 downto 0);
   signal rx_valid : std_logic;
   signal rx_ack : std_logic;
     
--   signal rx_clock : std_logic;
--   signal rx_valid : std_logic;
--   signal rx_error : std_logic;
--   signal rx_read  : std_logic;
--   signal rx_data  : std_logic_vector(7 downto 0);
--   signal rx_stb   : std_logic;
--   signal rx_ack   : std_logic;
   
   -- state constants
   constant MAX_STATES : integer := 12;

   constant RESET      : integer := 0;
   constant IDLE       : integer := 1;
   constant LED_POWER  : integer := 2;
   constant LED_STATUS : integer := 3;
   constant LED_FAULT  : integer := 4;
   constant DIP_SW     : integer := 5;      
   constant WATCHDOG   : integer := 6;  
   constant SLOTID     : integer := 7; 
   constant CARDID     : integer := 8;   
   constant DEBUG      : integer := 9;
   constant BER_RX     : integer := 10;
   constant BER_TX     : integer := 11;
      
   constant SEL_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (RESET => '1', others => '0');
   constant SEL_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (IDLE => '1', others => '0');
   constant SEL_LED_POWER  : std_logic_vector(MAX_STATES - 1 downto 0) := (LED_POWER => '1', others => '0');
   constant SEL_LED_STATUS : std_logic_vector(MAX_STATES - 1 downto 0) := (LED_STATUS => '1', others => '0');
   constant SEL_LED_FAULT  : std_logic_vector(MAX_STATES - 1 downto 0) := (LED_FAULT => '1', others => '0');
   constant SEL_DIP_SW     : std_logic_vector(MAX_STATES - 1 downto 0) := (DIP_SW => '1', others => '0');
   constant SEL_WATCHDOG   : std_logic_vector(MAX_STATES - 1 downto 0) := (WATCHDOG => '1', others => '0');        
   constant SEL_SLOT_ID    : std_logic_vector(MAX_STATES - 1 downto 0) := (SLOTID => '1', others => '0');
   constant SEL_CARD_ID    : std_logic_vector(MAX_STATES - 1 downto 0) := (CARDID => '1', others => '0');
   constant SEL_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (DEBUG => '1', others => '0');
   constant SEL_BER_RX     : std_logic_vector(MAX_STATES - 1 downto 0) := (BER_RX => '1', others => '0');
   constant SEL_BER_TX     : std_logic_vector(MAX_STATES - 1 downto 0) := (BER_TX => '1', others => '0');   
   
--   constant DONE_NULL       : std_logic_vector(MAX_STATES - 1 downto 0) := (others => '0');
   constant NOT_DONE        : std_logic_vector(MAX_STATES - 1 downto 0) := (others => '0');
   constant DONE_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (RESET => '1', others => '0');
   constant DONE_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (IDLE => '1', others => '0');
   constant DONE_LED_POWER  : std_logic_vector(MAX_STATES - 1 downto 0) := (LED_POWER => '1', others => '0');
   constant DONE_LED_STATUS : std_logic_vector(MAX_STATES - 1 downto 0) := (LED_STATUS => '1', others => '0');
   constant DONE_LED_FAULT  : std_logic_vector(MAX_STATES - 1 downto 0) := (LED_FAULT => '1', others => '0');
   constant DONE_DIP_SW     : std_logic_vector(MAX_STATES - 1 downto 0) := (DIP_SW => '1', others => '0');
   constant DONE_WATCHDOG   : std_logic_vector(MAX_STATES - 1 downto 0) := (WATCHDOG => '1', others => '0');
   constant DONE_SLOT_ID    : std_logic_vector(MAX_STATES - 1 downto 0) := (SLOTID => '1', others => '0');
   constant DONE_CARD_ID    : std_logic_vector(MAX_STATES - 1 downto 0) := (CARDID => '1', others => '0');
   constant DONE_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (DEBUG => '1', others => '0');
   constant DONE_BER_RX     : std_logic_vector(MAX_STATES - 1 downto 0) := (BER_RX => '1', others => '0');
   constant DONE_BER_TX     : std_logic_vector(MAX_STATES - 1 downto 0) := (BER_TX => '1', others => '0');  

   -- state signals
   type states is (INIT, FETCH, DECODE, EXECUTE);
   signal cmd_state : states;
   
   signal sel  : std_logic_vector(MAX_STATES - 1 downto 0);
   signal done : std_logic_vector(MAX_STATES - 1 downto 0);
   
   signal cmd1 : std_logic_vector(7 downto 0);
   signal cmd2 : std_logic_vector(7 downto 0);
   
   -- device return signals:
   signal reset_data    : std_logic_vector(7 downto 0);
   signal idle_data     : std_logic_vector(7 downto 0);
   signal dip_data      : std_logic_vector(7 downto 0);     
   signal slot_id_data  : std_logic_vector(7 downto 0);
   signal card_id_data  : std_logic_vector(7 downto 0);
   signal debug_data    : std_logic_vector(7 downto 0);
   
   signal reset_start      : std_logic;
   signal idle_start       : std_logic;
   signal dip_start        : std_logic;     
   signal slot_id_start    : std_logic;
   signal card_id_start    : std_logic;
   signal debug_start      : std_logic;
   
--   signal reset_stb     : std_logic;
--   signal idle_stb      : std_logic;
--   signal dip_stb       : std_logic;  
--   signal slot_id_stb   : std_logic;
--   signal card_id_stb   : std_logic;
--   signal debug_stb     : std_logic;
   
   signal test_data : std_logic_vector(39 downto 0);
   
begin
   clk_gen : all_test_pll
      port map(inclk0 => inclk,
               c0 => clk,
               c1 => comm_clk,
               e0 => outclk);

   -- RS232 interface start
   receiver : rs232_rx
      port map(clk_i => clk,
               comm_clk_i => comm_clk,
               rst_i => rst,
     
               dat_o => rx_data,
               rdy_o => rx_valid,
               ack_i => rx_ack,
     
               rs232_i => debug_rx);
   
   transmitter : rs232_tx
      port map(clk_i => clk,
               comm_clk_i => comm_clk,
               rst_i => rst,
     
               dat_i => tx_data,
               start_i => tx_start,
               done_o => tx_done,
     
               rs232_o => debug_tx);
     
--   receiver : async_rx
--      port map(rx_i => rs232_rx,
--               flag_o => rx_valid,
--               error_o => rx_error,
--               clk_i => rx_clock,
--               rst_i => rst,
--               dat_o => rx_data,
--               we_i => zero,
--               stb_i => rx_stb,
--               ack_o => rx_ack,
--               cyc_i => one);
--
--   transmitter : async_tx
--      port map(tx_o => rs232_tx,
--               busy_o => tx_busy,
--               clk_i => tx_clock,
--               rst_i => rst,
--               dat_i => tx_data,
--               we_i => tx_we,
--               stb_i => tx_stb,
--               ack_o => tx_ack,
--               cyc_i => one);
--   
--   aclock : async_clk
--      port map(clk_i => clk,
--               rst_i => rst,
--               txclk_o => tx_clock,
--               rxclk_o => rx_clock);
      
   -- RS232 interface end
   
   -- reset_state gives us our welcome string on startup
   reset_state : all_test_reset
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(RESET),
               done_o    => done(RESET),

               tx_data_o  => reset_data,
               tx_start_o => reset_start,
               tx_done_i  => tx_done);               
               
--               tx_busy_i => tx_busy,
--               tx_ack_i  => tx_ack,
--               tx_data_o => reset_data,
--               tx_we_o   => reset_we,
--               tx_stb_o  => reset_stb);
   
--   -- idle_state is special - it aquires commands for us to process
--   idle_state : all_test_idle
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_IDLE),
--               done_o    => done(INDEX_IDLE),
--               
--               tx_busy_i => tx_busy,
--               tx_ack_i  => tx_ack,
--               tx_data_o => idle_data,
--               tx_we_o   => idle_start,
--               tx_stb_o  => idle_stb,
--               
--               rx_valid_i => rx_valid,
--               rx_ack_i  => rx_ack,
--               rx_stb_o  => rx_stb,
--               rx_data_i => rx_data,
--               
--               cmd1_o => cmd1,
--               cmd2_o => cmd2);
--      
--   -- power led
--   led_power : led_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_LED_POWER),
--               done_o    => done(INDEX_LED_POWER),
--               led_o     => grn_led);
--   
--   -- status led
--   led_status : led_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_LED_STATUS),
--               done_o    => done(INDEX_LED_STATUS),
--               led_o     => ylw_led);
--   
--   -- fault led
--   led_fault : led_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_LED_FAULT),
--               done_o    => done(INDEX_LED_FAULT),
--               led_o     => red_led);
--      
--   -- watchdog timer
--   watchdog_timer : watchdog_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_WATCHDOG),
--               done_o    => done(INDEX_WATCHDOG),
--               wdt_o     => wdog);
--         
--   -- DIP switches
--   dip <= dip_sw3 & dip_sw4;
--   dip_sw : dip_switch_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_DIP),
--               done_o    => done(INDEX_DIP),
--               dip_switch_i => dip,
--
--               tx_busy_i => tx_busy,
--               tx_ack_i  => tx_ack,
--               tx_data_o => dip_data,
--               tx_we_o   => dip_start,
--               tx_stb_o  => dip_stb);
--     
--   slotid : slot_id_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_SLOT_ID),
--               done_o    => done(INDEX_SLOT_ID),
--               slot_id_i => slot_id,
--               
--               tx_busy_i => tx_busy,
--               tx_ack_i  => tx_ack,
--               tx_data_o => slot_id_data,
--               tx_we_o   => slot_id_start,
--               tx_stb_o  => slot_id_stb);
--               
--   cardid : card_id_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_CARD_ID),
--               done_o    => done(INDEX_CARD_ID),
--               data_bi   => card_id,
--               
--               tx_busy_i => tx_busy,
--               tx_ack_i  => tx_ack,
--               tx_data_o => card_id_data,
--               tx_we_o   => card_id_start,
--               tx_stb_o  => card_id_stb);    
--               
--   debug_tx : rs232_data_tx
--      generic map(WIDTH => 40)
--      port map(clk_i   => clk,
--               rst_i   => rst,
--               data_i  => test_data,
--               start_i => sel(INDEX_DEBUG),
--               done_o  => done(INDEX_DEBUG),
--
--               tx_busy_i => tx_busy,
--               tx_ack_i  => tx_ack,
--               tx_data_o => debug_data,
--               tx_we_o   => debug_start,
--               tx_stb_o  => debug_stb); 
--      
   zero <= '0';
   one <= '1';                         
   rst <= not n_rst or int_rst;
   test_data <= "1011101011011010010101011011101010111110";  -- 0xBADA55BABE
   
   -- functionality of async_mux:
   
   with sel select
      tx_data <= reset_data    when SEL_RESET,
                 idle_data     when SEL_IDLE,
                 dip_data      when SEL_DIP_SW,
                 slot_id_data  when SEL_SLOT_ID,
                 card_id_data  when SEL_CARD_ID,
                 debug_data    when SEL_DEBUG,
                 "00000000"    when others;
   
   with sel select
      tx_start <= reset_start   when SEL_RESET,
                  idle_start    when SEL_IDLE,
                  dip_start     when SEL_DIP_SW,
                  slot_id_start when SEL_SLOT_ID,
                  card_id_start when SEL_CARD_ID,
                  debug_start   when SEL_DEBUG,
                  '0'           when others; 
   
--   with sel select
--      tx_stb  <= reset_stb     when SEL_RESET,
--                 idle_stb      when SEL_IDLE,
--                 dip_stb       when SEL_DIP,
--                 slot_id_stb   when SEL_SLOT_ID,
--                 card_id_stb   when SEL_CARD_ID,
--                 debug_stb     when SEL_DEBUG,
--                 '0'           when others;
   
   -- cmd_proc is our main processing state machine
   cmd_proc : process (rst, clk)
   begin
      if (rst = '1') then
         int_rst <= '0';
         sel <= SEL_RESET;
         cmd_state <= INIT;
      elsif Rising_Edge(clk) then
         case cmd_state is
            when INIT => 
               -- wait for the reset state to complete
               if (done = DONE_RESET) then
                  cmd_state <= FETCH;
               else
                  cmd_state <= cmd_state;
               end if;
               sel <= SEL_RESET;
               
            when FETCH =>
               -- wait for a command to be decoded
               if (done = DONE_IDLE) then
                  cmd_state <= DECODE;
               else
                  cmd_state <= cmd_state;
               end if;
               sel <= SEL_IDLE;
               
            when DECODE =>
               -- activate the appropiate test module
               cmd_state <= EXECUTE;
               if(cmd1 = CMD_LED) then
                  -- toggle a LED
                  if (cmd2 = CMD_LED_1) then
                     sel <= SEL_LED_POWER;
                  elsif (cmd2 = CMD_LED_2) then
                     sel <= SEL_LED_STATUS;
                  else
                     sel <= SEL_LED_FAULT;
                  end if;
                     
               elsif(cmd1 = CMD_WATCHDOG) then
                  -- kick watchdog
                  sel <= SEL_WATCHDOG;
                  
               elsif(cmd1 = CMD_DIP) then
                  -- read DIP switch
                  sel <= SEL_DIP_SW;
                  
               elsif(cmd1 = CMD_SLOT_ID) then
                  sel <= SEL_SLOT_ID;
               
               elsif(cmd1 = CMD_CARD_ID) then
                  sel <= SEL_CARD_ID;

               elsif(cmd1 = CMD_DEBUG) then
                  sel <= SEL_DEBUG;
                  
               elsif(cmd1 = CMD_RESET) then
                  int_rst <= '1';
                  
               else
                  -- must not be implemented yet!
                  sel <= (others => '0');
                  cmd_state <= FETCH;                  
               end if;
               
            when EXECUTE =>
               -- wait for thet test to complete
               if (done = NOT_DONE) then
                  cmd_state <= EXECUTE;
               else
                  int_rst <= '0';
                  sel <= (others => '0');
                  cmd_state <= FETCH;
               end if;
               
--               if (done /= DONE_NULL) then
--                  int_rst <= '0';
--                  sel <= (others => '0');
--                  cmd_state <= FETCH;
--               end if;
               
            when others =>
               sel <= (others => '0');
               cmd_state <= INIT;
         end case;
      end if;
   end process cmd_proc;

   test(15 downto 11) <= sel(4 downto 0); -- sel(reset) to test pin 11

end behaviour;
