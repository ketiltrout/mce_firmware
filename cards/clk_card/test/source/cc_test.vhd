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
-- cc_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test module for clock card
--
-- Revision history:
-- 
-- $Log: cc_test.vhd,v $
-- Revision 1.3  2004/06/09 22:13:38  erniel
-- initial version
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.async_pack.all;
use work.cc_test_pack.all;

entity cc_test is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk : in std_logic;
      outclk : out std_logic;
      
      -- RS232 interface
      rs232_tx : out std_logic;
      rs232_rx : in std_logic;
      
      -- box id interface
      box_id_in : in std_logic;
      box_id_out : out std_logic;
      box_id_ena : out std_logic;
            
      -- array id interface
      array_id : in std_logic_vector(2 downto 0);
      
      -- LVDS interfaces
      lvds_cmd : out std_logic;
      lvds_sync : out std_logic;
      lvds_spare : out std_logic;

      lvds_rx0a : in std_logic;
      lvds_rx0b : in std_logic;
      lvds_rx1a : in std_logic;
      lvds_rx1b : in std_logic;
      lvds_rx2a : in std_logic;
      lvds_rx2b : in std_logic;
      lvds_rx3a : in std_logic;
      lvds_rx3b : in std_logic;
      lvds_rx4a : in std_logic;
      lvds_rx4b : in std_logic;
      lvds_rx5a : in std_logic;
      lvds_rx5b : in std_logic;
      lvds_rx6a : in std_logic;
      lvds_rx6b : in std_logic;      
      lvds_rx7a : in std_logic;
      lvds_rx7b : in std_logic;
      
      -- SRAM bank 1 interface
      sram0_addr : out std_logic_vector(19 downto 0);
      sram0_data : inout std_logic_vector(15 downto 0);
      sram0_nbhe : out std_logic;
      sram0_nble : out std_logic;
      sram0_noe : out std_logic;
      sram0_nwe : out std_logic;
      sram0_ncs : out std_logic;
      
      -- SRAM bank 1 interface
      sram1_addr : out std_logic_vector(19 downto 0);
      sram1_data : inout std_logic_vector(15 downto 0);
      sram1_nbhe : out std_logic;
      sram1_nble : out std_logic;
      sram1_noe : out std_logic;
      sram1_nwe : out std_logic;
      sram1_ncs : out std_logic;
      
      -- EEPROM interface
      eeprom_si : in std_logic;
      eeprom_so : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs : out std_logic;
      test      : out std_logic_vector(38 downto 11));
      
      -- Fibre interface
      
end cc_test;

architecture behaviour of cc_test is
   
   -- pll output allocation:
   --    c0 = FPGA system clock
   --    c1 = Asynchronous Transfer clock
   --    e0 = backplane LVDS clock
   --    e1 = fibre transmitter
   --    e2 = fibre receiver
   --    e3 = PLL observation
   
--   component pll
--   port(inclk0 : in std_logic;
--        c0 : out std_logic;
 --       c1 : out std_logic;
 --       e0 : out std_logic;
  --      e1 : out std_logic;
  --      e2 : out std_logic;
   --     e3 : out std_logic);
 --  end component;
component pll IS
	PORT
	(
		inclk0		: IN STD_LOGIC ;
		c1              : OUT STD_LOGIC;
		e0		: OUT STD_LOGIC 
	);
END component;

   -- clock signals
   signal clk : std_logic;         -- general system clock (50 MHz)
   signal clk2 : std_logic;   -- special clock to async xfer modules (200 MHz)
   
   signal zero : std_logic;
   signal one : std_logic;
   
--   signal clk : std_logic;   
   signal rst : std_logic;
   signal cmd_rst : std_logic;
   
   signal dip : std_logic_vector(1 downto 0);

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
   
   -- state constants
   constant MAX_STATES : integer := 30;

   constant INDEX_RESET      : integer := 0;
   constant INDEX_IDLE       : integer := 1;
   constant INDEX_BOX_ID     : integer := 2;
   constant INDEX_ARRAY_ID   : integer := 3;
   constant INDEX_EEPROM     : integer := 4;
   constant INDEX_TX_CMD     : integer := 5;
   constant INDEX_TX_SYNC    : integer := 6;
   constant INDEX_TX_SPARE   : integer := 7;
   constant INDEX_RX_0A      : integer := 8;
   constant INDEX_RX_0B      : integer := 9;
   constant INDEX_RX_1A      : integer := 10;
   constant INDEX_RX_1B      : integer := 11;
   constant INDEX_RX_2A      : integer := 12;
   constant INDEX_RX_2B      : integer := 13;
   constant INDEX_RX_3A      : integer := 14;
   constant INDEX_RX_3B      : integer := 15;
   constant INDEX_RX_4A      : integer := 16;
   constant INDEX_RX_4B      : integer := 17;
   constant INDEX_RX_5A      : integer := 18;
   constant INDEX_RX_5B      : integer := 19;
   constant INDEX_RX_6A      : integer := 20;
   constant INDEX_RX_6B      : integer := 21;
   constant INDEX_RX_7A      : integer := 22;
   constant INDEX_RX_7B      : integer := 23; 
   constant INDEX_SRAM_1     : integer := 24;
   constant INDEX_SRAM_2     : integer := 25;
   constant INDEX_FIBRE_BIST : integer := 26;
   constant INDEX_FIBRE_TX   : integer := 27;  
   constant INDEX_FIBRE_RX   : integer := 28;
   constant INDEX_DEBUG      : integer := 29;
      
   constant SEL_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant SEL_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant SEL_BOX_ID     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_BOX_ID => '1', others => '0');
   constant SEL_ARRAY_ID   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_ARRAY_ID => '1', others => '0');
   constant SEL_EEPROM     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_EEPROM => '1', others => '0');
   constant SEL_TX_CMD     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_CMD => '1', others => '0');
   constant SEL_TX_SYNC    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_SYNC => '1', others => '0');
   constant SEL_TX_SPARE   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_SPARE => '1', others => '0');
   constant SEL_RX_0A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_0A => '1', others => '0');
   constant SEL_RX_0B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_0B => '1', others => '0');
   constant SEL_RX_1A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_1A => '1', others => '0');
   constant SEL_RX_1B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_1B => '1', others => '0');
   constant SEL_RX_2A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_2A => '1', others => '0');
   constant SEL_RX_2B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_2B => '1', others => '0');
   constant SEL_RX_3A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_3A => '1', others => '0');
   constant SEL_RX_3B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_3B => '1', others => '0');
   constant SEL_RX_4A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_4A => '1', others => '0');
   constant SEL_RX_4B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_4B => '1', others => '0');
   constant SEL_RX_5A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_5A => '1', others => '0');
   constant SEL_RX_5B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_5B => '1', others => '0');
   constant SEL_RX_6A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_6A => '1', others => '0');
   constant SEL_RX_6B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_6B => '1', others => '0');
   constant SEL_RX_7A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_7A => '1', others => '0');
   constant SEL_RX_7B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_7B => '1', others => '0');
   constant SEL_SRAM_1     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_1 => '1', others => '0'); 
   constant SEL_SRAM_2     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_2 => '1', others => '0');   
   constant SEL_FIBRE_BIST : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_FIBRE_BIST => '1', others => '0'); 
   constant SEL_FIBRE_TX   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_FIBRE_TX => '1', others => '0'); 
   constant SEL_FIBRE_RX   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_FIBRE_RX => '1', others => '0'); 
   constant SEL_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DEBUG => '1', others => '0');
   
   constant WAIT_DONE       : std_logic_vector(MAX_STATES - 1 downto 0) := (others => '0');
   constant DONE_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant DONE_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant DONE_BOX_ID     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_BOX_ID => '1', others => '0');
   constant DONE_ARRAY_ID   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_ARRAY_ID => '1', others => '0');
   constant DONE_EEPROM     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_EEPROM => '1', others => '0');
   constant DONE_TX_CMD     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_CMD => '1', others => '0');
   constant DONE_TX_SYNC    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_SYNC => '1', others => '0');
   constant DONE_TX_SPARE   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_SPARE => '1', others => '0');
   constant DONE_RX_0A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_0A => '1', others => '0');
   constant DONE_RX_0B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_0B => '1', others => '0');
   constant DONE_RX_1A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_1A => '1', others => '0');
   constant DONE_RX_1B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_1B => '1', others => '0');
   constant DONE_RX_2A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_2A => '1', others => '0');
   constant DONE_RX_2B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_2B => '1', others => '0');
   constant DONE_RX_3A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_3A => '1', others => '0');
   constant DONE_RX_3B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_3B => '1', others => '0');
   constant DONE_RX_4A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_4A => '1', others => '0');
   constant DONE_RX_4B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_4B => '1', others => '0');
   constant DONE_RX_5A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_5A => '1', others => '0');
   constant DONE_RX_5B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_5B => '1', others => '0');
   constant DONE_RX_6A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_6A => '1', others => '0');
   constant DONE_RX_6B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_6B => '1', others => '0');
   constant DONE_RX_7A      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_7A => '1', others => '0');
   constant DONE_RX_7B      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_7B => '1', others => '0');
   constant DONE_SRAM_1     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_1 => '1', others => '0'); 
   constant DONE_SRAM_2     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_2 => '1', others => '0');   
   constant DONE_FIBRE_BIST : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_FIBRE_BIST => '1', others => '0'); 
   constant DONE_FIBRE_TX   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_FIBRE_TX => '1', others => '0'); 
   constant DONE_FIBRE_RX   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_FIBRE_RX => '1', others => '0');
   constant DONE_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DEBUG => '1', others => '0');

   -- state signals
   type states is (RESET, FETCH, DECODE, EXECUTE);
   signal cmd_state : states;
   
   signal sel  : std_logic_vector(MAX_STATES - 1 downto 0);
   signal done : std_logic_vector(MAX_STATES - 1 downto 0);
   
   signal cmd1 : std_logic_vector(7 downto 0);
   signal cmd2 : std_logic_vector(7 downto 0);
   signal cmd3 : std_logic_vector(7 downto 0);
   
   -- device return signals:
   signal reset_data    : std_logic_vector(7 downto 0);
   signal idle_data     : std_logic_vector(7 downto 0);
   signal dip_data      : std_logic_vector(7 downto 0);
   signal array_id_data : std_logic_vector(7 downto 0);     
   signal slot_id_data  : std_logic_vector(7 downto 0);
   signal card_id_data  : std_logic_vector(7 downto 0);
   signal debug_data    : std_logic_vector(7 downto 0);
   
   signal reset_we      : std_logic;
   signal idle_we       : std_logic;
   signal dip_we        : std_logic;  
   signal array_id_we   : std_logic;   
   signal slot_id_we    : std_logic;
   signal card_id_we    : std_logic;
   signal debug_we      : std_logic;
   
   signal reset_stb     : std_logic;
   signal idle_stb      : std_logic;
   signal dip_stb       : std_logic;
   signal array_id_stb  : std_logic;  
   signal slot_id_stb   : std_logic;
   signal card_id_stb   : std_logic;
   signal debug_stb     : std_logic;
   
   signal test_data : std_logic_vector(39 downto 0);
   
   signal dummy0,dummy1 : std_logic;
   signal pass0,pass1,pass   : std_logic;
   signal fail0,fail1,fail   : std_logic;
   
   
begin
   clk_gen : pll
      port map(inclk0 => inclk,
               c1 => clk,
               e0 => outclk);

   -- RS232 interface start
   receiver : async_rx
      port map(rx_i => rs232_rx,
               flag_o => rx_valid,
               error_o => rx_error,
               clk_i => rx_clock,
               rst_i => rst,
               dat_o => rx_data,
               we_i => zero,
               stb_i => rx_stb,
               ack_o => rx_ack,
               cyc_i => one);

   transmitter : async_tx
      port map(tx_o => rs232_tx,
               busy_o => tx_busy,
               clk_i => tx_clock,
               rst_i => rst,
               dat_i => tx_data,
               we_i => tx_we,
               stb_i => tx_stb,
               ack_o => tx_ack,
               cyc_i => one);
   
   aclock : async_clk
      port map(clk_i => clk,
               rst_i => rst,
               txclk_o => tx_clock,
               rxclk_o => rx_clock);
      
   -- RS232 interface end
   
   -- reset_state gives us our welcome string on startup
   reset_state : cc_test_reset
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_RESET),
               done_o    => done(INDEX_RESET),
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => reset_data,
               tx_we_o   => reset_we,
               tx_stb_o  => reset_stb);
   
   -- idle_state is special - it aquires commands for us to process
   idle_state : cc_test_idle
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_IDLE),
               done_o    => done(INDEX_IDLE),
               
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
               cmd2_o => cmd2,
               cmd3_o => cmd3);
     
--   boxid : box_id_test_wrapper
--      port map(rst_i     => rst,
--               clk_i     => clk,
--               en_i      => sel(INDEX_BOX_ID),
--               done_o    => done(INDEX_BOX_ID),
--               data_bi   => box_id,
--               
--               tx_busy_i => tx_busy,
--               tx_ack_i  => tx_ack,
--               tx_data_o => box_id_data,
--               tx_we_o   => box_id_we,
--               tx_stb_o  => box_id_stb);    
--   
--   box_id <= box_id_out when box_id_ena = '1', else box_id_in;
               
   arrayid : array_id_test_wrapper
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_ARRAY_ID),
               done_o    => done(INDEX_ARRAY_ID),
      
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => array_id_data,
               tx_we_o   => array_id_we,
               tx_stb_o  => array_id_stb,
     
               array_id_i => array_id);
               
   debug_tx : rs232_data_tx
      generic map(WIDTH => 40)
      port map(clk_i   => clk,
               rst_i   => rst,
               data_i  => test_data,
               start_i => sel(INDEX_DEBUG),
               done_o  => done(INDEX_DEBUG),

               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => debug_data,
               tx_we_o   => debug_we,
               tx_stb_o  => debug_stb); 
   
   sram1 : sram_test_wrapper 
      port map(-- test control signals
               rst_i    => rst,
               clk_i    => clk,
               en_i     => sel(INDEX_SRAM_1),
               done_o   => done(INDEX_SRAM_1),
                
               -- RS232 signals
                
               -- physical pins
               addr_o   => sram0_addr,
               data_bi  => sram0_data,
               n_ble_o  => sram0_nbhe,
               n_bhe_o  => sram0_nble,
               n_oe_o   => sram0_noe, 
               n_ce1_o  => sram0_ncs, 
               ce2_o    => dummy0, 
               n_we_o   => sram0_nwe,
               pass     => pass0,
               fail     => fail0);

   sram2 : sram_test_wrapper 
      port map(-- test control signals
               rst_i    => rst,
               clk_i    => clk,
               en_i     => sel(INDEX_SRAM_2),
               done_o   => done(INDEX_SRAM_2),
                
               -- RS232 signals
                
               -- physical pins
               addr_o   => sram1_addr,
               data_bi  => sram1_data,
               n_ble_o  => sram1_nbhe,
               n_bhe_o  => sram1_nble,
               n_oe_o   => sram1_noe, 
               n_ce1_o  => sram1_ncs, 
               ce2_o    => dummy1, 
               n_we_o   => sram1_nwe,
               pass     => pass1,
               fail     => fail1);
   fail <= fail1 or fail0;
   pass <= pass1 or pass0;
   zero <= '0';
   one <= '1';                         
   rst <= not n_rst or cmd_rst;
   test_data <= "1011101011011010010101011011101010111110";  -- 0xBADA55BABE
   
   -- functionality of async_mux:
   
   with sel select
      tx_data <= reset_data    when SEL_RESET,
                 idle_data     when SEL_IDLE,
                 debug_data    when SEL_DEBUG,
                 "00000000"    when others;
   
   with sel select
      tx_we   <= reset_we      when SEL_RESET,
                 idle_we       when SEL_IDLE,
                 debug_we      when SEL_DEBUG,
                 '0'           when others; 
   
   with sel select
      tx_stb  <= reset_stb     when SEL_RESET,
                 idle_stb      when SEL_IDLE,
                 debug_stb     when SEL_DEBUG,
                 '0'           when others;
   
   -- cmd_proc is our main processing state machine
   cmd_proc : process (rst, clk)
   begin
      if (rst = '1') then
         cmd_rst <= '0';
         sel <= SEL_RESET;
         cmd_state <= RESET;
      elsif Rising_Edge(clk) then
         case cmd_state is
            when RESET => 
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
               if(cmd1 = CMD_SRAM and cmd2 = CMD_SRAM_1) then
                  sel <= SEL_SRAM_1;
               elsif(cmd1 = CMD_SRAM and cmd2 = CMD_SRAM_2) then
                  sel <= SEL_SRAM_2;
               elsif(cmd1 = CMD_TX and cmd2 = CMD_TX_CMD) then
                  sel <= SEL_TX_CMD;
               elsif(cmd1 = CMD_TX and cmd2 = CMD_TX_SYNC) then
                  sel <= SEL_TX_SYNC;
               elsif(cmd1 = CMD_TX and cmd2 = CMD_TX_SPARE) then
                  sel <= SEL_TX_SPARE;
                              
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_0 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_0A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_0 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_0B;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_1 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_1A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_1 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_1B;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_2 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_2A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_2 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_2B;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_3 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_3A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_3 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_3B;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_4 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_4A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_4 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_4B;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_5 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_5A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_5 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_5B;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_6 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_6A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_6 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_6B;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_7 and cmd3 = CMD_RX_A) then
                  sel <= SEL_RX_7A;
               elsif(cmd1 = CMD_RX and cmd2 = CMD_RX_7 and cmd3 = CMD_RX_B) then
                  sel <= SEL_RX_7B;
                     
                  
               elsif(cmd1 = CMD_FIBRE and cmd2 = CMD_FIBRE_BIST) then
                  sel <= SEL_FIBRE_BIST;
               elsif(cmd1 = CMD_FIBRE and cmd2 = CMD_FIBRE_TX) then
                  sel <= SEL_FIBRE_TX;
               elsif(cmd1 = CMD_FIBRE and cmd2 = CMD_FIBRE_RX) then
                  sel <= SEL_FIBRE_RX;                     
                  
               elsif(cmd1 = CMD_BOX_ID) then
                  sel <= SEL_BOX_ID;
                  
               elsif(cmd1 = CMD_ARRAY_ID) then
                  sel <= SEL_ARRAY_ID;
                  
               elsif(cmd1 = CMD_EEPROM) then
                  sel <= SEL_EEPROM;

               elsif(cmd1 = CMD_DEBUG) then
                  sel <= SEL_DEBUG;
                  
               elsif(cmd1 = CMD_RESET) then
                  cmd_rst <= '1';
                  
               else
                  -- must not be implemented yet!
                  sel <= (others => '0');
                  cmd_state <= FETCH;                  
               end if;
               
            when EXECUTE =>
               -- wait for thet test to complete
               if (done /= WAIT_DONE) then
                  cmd_rst <= '0';
                  sel <= (others => '0');
                  cmd_state <= FETCH;
               end if;
               
            when others =>
               sel <= (others => '0');
               cmd_state <= RESET;
         end case;
      end if;
   end process cmd_proc;
   test(26) <= pass0 or pass1;
   test(28) <= fail0 or fail1;
   test(30) <= sel(INDEX_SRAM_1) or sel(INDEX_SRAM_2);
   test(32) <= sram0_data(1);
--   test(34) <= dummy;

end behaviour;
