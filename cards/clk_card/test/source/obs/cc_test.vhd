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
-- Reset state function.
-- 
-- Revision History:
-- Jan 17, 2004: Initial version - NRG
-- Feb 28, 2004: Updated so that MAX_STATES is fully parameterized. - NRG
-- Mar 01, 2004: Added s_led states. - NRG
--
-- CVS Logs:
--
-- $Log: cc_test.vhd,v $
-- Revision 1.1  2004/05/20 23:51:14  erniel
-- relocated old cc_test files
--
-- Revision 1.1  2004/04/14 22:16:23  jjacob
-- new directory structure
--
-- Revision 1.6  2004/04/02 17:50:57  bburger
-- Added ArrayID functionality
--
-- Revision 1.5  2004/03/27 03:24:59  erniel
-- Added Card ID and Slot ID modules
--
-- Revision 1.4  2004/03/27 01:01:34  erniel
-- Added SRAM verification module
--
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.async_pack.all;
use work.s_pack.all;

entity cc_test is
   port(
      reset_n : in std_logic;
      clk : in std_logic;
      txd : out std_logic;
      rxd : in std_logic;
      
      -- led interface
      led : out std_logic_vector(2 downto 0);
      
      -- watchdog timer interface                      
      wdt : out std_logic;
      
      -- LVDS transmit interface
      sync : out std_logic;
      cmd : out std_logic;
      txspare : out std_logic;
      
      -- SRAM interface
      sram0_addr : out std_logic_vector(19 downto 0);
      sram0_data : inout std_logic_vector(15 downto 0);
      sram0_nble : out std_logic;
      sram0_nbhe : out std_logic;
      sram0_noe  : out std_logic;
      sram0_nce1 : out std_logic;
      sram0_ce2  : out std_logic;
      sram0_nwe  : out std_logic;
            
      sram1_addr : out std_logic_vector(19 downto 0);
      sram1_data : inout std_logic_vector(15 downto 0);
      sram1_nble : out std_logic;
      sram1_nbhe : out std_logic;
      sram1_noe  : out std_logic;
      sram1_nce1 : out std_logic;
      sram1_ce2  : out std_logic;
      sram1_nwe  : out std_logic;
      
      -- slot id interface
      slot_id : in std_logic_vector (3 downto 0);
      
      -- array id interface
      array_id : in std_logic_vector (2 downto 0);
      
      -- card id interface
      card_id : inout std_logic
      
   );
end cc_test;

architecture behaviour of cc_test is
   
   constant MAX_STATES : integer := 14;
   signal zero : std_logic;
   signal one : std_logic;
   signal reset : std_logic;

   -- transmitter signals
   signal tx_clock : std_logic;
   signal tx_busy : std_logic;
   signal tx_strobe : std_logic;
   signal tx_rec : tx_t;
   signal tx_rec_array : tx_array(MAX_STATES - 1 downto 0);
   signal tx_ack : std_logic;
   
   -- reciever signals
   signal rx_clock : std_logic;
   signal rx_flag : std_logic;
   signal rx_error : std_logic;
   signal rx_read : std_logic;
   signal rx_data : std_logic_vector(7 downto 0);
   signal rx_stb : std_logic;
   signal rx_ack : std_logic;
   
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
   constant INDEX_SRAM_0        : integer := 9;
   constant INDEX_SRAM_1        : integer := 10;
   constant INDEX_SLOT_ID       : integer := 11;
   constant INDEX_CARD_ID       : integer := 12;
   constant INDEX_ARRAY_ID      : integer := 13;
   
   constant SEL_RESET          : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant SEL_IDLE           : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant SEL_LED_POWER      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_POWER => '1', others => '0');
   constant SEL_LED_STATUS     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_STATUS => '1', others => '0');
   constant SEL_LED_FAULT      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LED_FAULT => '1', others => '0');
   constant SEL_WATCHDOG       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_WATCHDOG => '1', others => '0');
   constant SEL_LVDS_TX_CMD    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_CMD => '1', others => '0');
   constant SEL_LVDS_TX_SYNC   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_SYNC => '1', others => '0');
   constant SEL_LVDS_TX_SPARE  : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_LVDS_TX_SPARE => '1', others => '0');
   constant SEL_SRAM_0         : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_0 => '1', others => '0');
   constant SEL_SRAM_1         : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_1 => '1', others => '0');
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
   constant DONE_SRAM_0        : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_0 => '1', others => '0');
   constant DONE_SRAM_1        : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM_1 => '1', others => '0');
   constant DONE_SLOT_ID       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SLOT_ID => '1', others => '0');
   constant DONE_CARD_ID       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_CARD_ID => '1', others => '0');
   constant DONE_ARRAY_ID      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_ARRAY_ID => '1', others => '0');

begin
   -- RS232 interface start
   receiver : async_rx
      port map(
         rx_i => rxd,
         flag_o => rx_flag,
         error_o => rx_error,
         clk_i => rx_clock,
         rst_i => reset,
         dat_o => rx_data,
         we_i => zero,
         stb_i => rx_stb,
         ack_o => rx_ack,
         cyc_i => one
      );

   transmitter : async_tx
      port map(
         tx_o => txd,
         busy_o => tx_busy,
         clk_i => tx_clock,
         rst_i => reset,
         dat_i => tx_rec.dat,
         we_i => tx_rec.we,
         stb_i => tx_rec.stb,
         ack_o => tx_ack,
         cyc_i => one
      );
   
   aclock : async_clk
      port map(
         clk_i => clk,
         rst_i => reset,
         txclk_o => tx_clock,
         rxclk_o => rx_clock
      );
      
   amux : async_mux
      generic map (size => MAX_STATES)
      port map(
         rst_i => reset,
         clk_i => clk,
         sel_i => sel_vec,
         in_i => tx_rec_array,
         out_o => tx_rec
      );
      
   -- RS232 interface end
   
   -- Command states start
   
   -- reset_state gives us our welcome string on startup
   reset_state : s_reset
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_RESET),
         done_o => done_vec(INDEX_RESET),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_RESET).dat,
         tx_we_o => tx_rec_array(INDEX_RESET).we,
         tx_stb_o => tx_rec_array(INDEX_RESET).stb
      );
   
   -- idle_state is special - it aquires commands for us to process
   idle_state : s_idle
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_IDLE),
         done_o => done_vec(INDEX_IDLE),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_IDLE).dat,
         tx_we_o => tx_rec_array(INDEX_IDLE).we,
         tx_stb_o => tx_rec_array(INDEX_IDLE).stb,
         cmd1_o => cmd1,
         cmd2_o => cmd2,
         rx_flag_i => rx_flag,
         rx_ack_i => rx_ack,
         rx_stb_o => rx_stb,
         rx_data_i => rx_data
      );
      
   -- power led state
   led_power_state : s_led
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_LED_POWER),
         done_o => done_vec(INDEX_LED_POWER),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_LED_POWER).dat,
         tx_we_o => tx_rec_array(INDEX_LED_POWER).we,
         tx_stb_o => tx_rec_array(INDEX_LED_POWER).stb,
         led_o => led(0)
      );
   
   -- status led state
   led_status_state : s_led
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_LED_STATUS),
         done_o => done_vec(INDEX_LED_STATUS),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_LED_STATUS).dat,
         tx_we_o => tx_rec_array(INDEX_LED_STATUS).we,
         tx_stb_o => tx_rec_array(INDEX_LED_STATUS).stb,
         led_o => led(1)
      );
   
   -- fault led state
   led_fault_state : s_led
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_LED_FAULT),
         done_o => done_vec(INDEX_LED_FAULT),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_LED_FAULT).dat,
         tx_we_o => tx_rec_array(INDEX_LED_FAULT).we,
         tx_stb_o => tx_rec_array(INDEX_LED_FAULT).stb,
         led_o => led(2)
      );
      
   -- watchdog timer
   watchdog_timer : s_watchdog
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_WATCHDOG),
         done_o => done_vec(INDEX_WATCHDOG),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_WATCHDOG).dat,
         tx_we_o => tx_rec_array(INDEX_WATCHDOG).we,
         tx_stb_o => tx_rec_array(INDEX_WATCHDOG).stb,
         wdt_o => wdt
      );
         
   -- LVDS CMD transmitter
   lvds_cmd : s_lvds_tx
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_LVDS_TX_CMD),
         done_o => done_vec(INDEX_LVDS_TX_CMD),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_LVDS_TX_CMD).dat,
         tx_we_o => tx_rec_array(INDEX_LVDS_TX_CMD).we,
         tx_stb_o => tx_rec_array(INDEX_LVDS_TX_CMD).stb,
         lvds_o => cmd
      );
   
   -- LVDS SYNC transmitter
   lvds_sync : s_lvds_tx
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_LVDS_TX_SYNC),
         done_o => done_vec(INDEX_LVDS_TX_SYNC),
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_LVDS_TX_SYNC).dat,
         tx_we_o => tx_rec_array(INDEX_LVDS_TX_SYNC).we,
         tx_stb_o => tx_rec_array(INDEX_LVDS_TX_SYNC).stb,
         lvds_o => sync
      );

   -- LVDS SPARE transmitter
   lvds_spare : s_lvds_tx
      port map (
         rst_i => reset,
         clk_i => clk,
         en_i => sel_vec(INDEX_LVDS_TX_SPARE),
         done_o => done_vec(INDEX_LVDS_TX_SPARE), 
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_rec_array(INDEX_LVDS_TX_SPARE).dat,
         tx_we_o => tx_rec_array(INDEX_LVDS_TX_SPARE).we,
         tx_stb_o => tx_rec_array(INDEX_LVDS_TX_SPARE).stb,
         lvds_o => txspare
      );
      
   sram0 : sram_test_wrapper
      port map(rst_i  => reset,
               clk_i  => clk,
               en_i   => sel_vec(INDEX_SRAM_0),
               done_o => done_vec(INDEX_SRAM_0),
      
               -- RS232 signals
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => tx_rec_array(INDEX_SRAM_0).dat,
               tx_we_o   => tx_rec_array(INDEX_SRAM_0).we,
               tx_stb_o  => tx_rec_array(INDEX_SRAM_0).stb,
      
               -- physical pins
               addr_o  => sram0_addr,
               data_bi => sram0_data,
               n_ble_o => sram0_nble,
               n_bhe_o => sram0_nbhe,
               n_oe_o  => sram0_noe,
               n_ce1_o => sram0_nce1,
               ce2_o   => sram0_ce2,
               n_we_o  => sram0_nwe);
   
   sram1 : sram_test_wrapper
      port map(rst_i  => reset,
               clk_i  => clk,
               en_i   => sel_vec(INDEX_SRAM_1),
               done_o => done_vec(INDEX_SRAM_1),
      
               -- RS232 signals
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => tx_rec_array(INDEX_SRAM_1).dat,
               tx_we_o   => tx_rec_array(INDEX_SRAM_1).we,
               tx_stb_o  => tx_rec_array(INDEX_SRAM_1).stb,
      
               -- physical pins
               addr_o  => sram1_addr,
               data_bi => sram1_data,
               n_ble_o => sram1_nble,
               n_bhe_o => sram1_nbhe,
               n_oe_o  => sram1_noe,
               n_ce1_o => sram1_nce1,
               ce2_o   => sram1_ce2,
               n_we_o  => sram1_nwe);
                 
   slotid : slot_id_test_wrapper
      port map(rst_i  => reset,
               clk_i  => clk,
               en_i   => sel_vec(INDEX_SLOT_ID),
               done_o => done_vec(INDEX_SLOT_ID),
      
               -- RS232 signals
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => tx_rec_array(INDEX_SLOT_ID).dat,
               tx_we_o   => tx_rec_array(INDEX_SLOT_ID).we,
               tx_stb_o  => tx_rec_array(INDEX_SLOT_ID).stb,
        
               -- physical pins
               slot_id_i => slot_id);
               
   cardid : card_id_test_wrapper
      port map(rst_i => reset,
               clk_i     => clk,
               en_i      => sel_vec(INDEX_CARD_ID),
               done_o    => done_vec(INDEX_CARD_ID),
      
               -- RS232 signals
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => tx_rec_array(INDEX_CARD_ID).dat,
               tx_we_o   => tx_rec_array(INDEX_CARD_ID).we,
               tx_stb_o  => tx_rec_array(INDEX_CARD_ID).stb,
      
               -- physical pins
               data_bi => card_id);
               
   arrayid : s_array_id
      port map(
         rst_i  => reset,
         clk_i  => clk,
         en_i   => sel_vec(INDEX_ARRAY_ID),
         done_o => done_vec(INDEX_ARRAY_ID),
        
         -- RS232 signals
         tx_busy_i => tx_busy,
         tx_ack_i  => tx_ack,
         tx_data_o => tx_rec_array(INDEX_ARRAY_ID).dat,
         tx_we_o   => tx_rec_array(INDEX_ARRAY_ID).we,
         tx_stb_o  => tx_rec_array(INDEX_ARRAY_ID).stb,
        
         -- physical pins
         array_id_i => array_id
      );
      
      
   zero <= '0';
   one <= '1';                         
   reset <= not reset_n;
   
   -- cmd_proc is our main processing state machine
   cmd_proc : process (reset, clk)
   begin
      if (reset = '1') then
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
               case cmd1 is
                  when CMD_LED =>
                     -- toggle a LED
                     if (cmd2 = CMD_LED_0) then
                        sel_vec <= SEL_LED_POWER;
                     elsif (cmd2 = CMD_LED_1) then
                        sel_vec <= SEL_LED_STATUS;
                     else
                        sel_vec <= SEL_LED_FAULT;
                     end if;
                     
                  when CMD_WATCHDOG =>
                     -- kick watchdog
                     sel_vec <= SEL_WATCHDOG;
                     
                  when CMD_TX =>
                     -- random number tx test
                     if (cmd2 = CMD_TX_0) then
                        sel_vec <= SEL_LVDS_TX_CMD;
                     elsif (cmd2 = CMD_TX_1) then
                        sel_vec <= SEL_LVDS_TX_SYNC;
                     else
                        sel_vec <= SEL_LVDS_TX_SPARE;
                     end if;
                  
                  when CMD_SRAM =>
                     -- SRAM verification
                     if(cmd2 = CMD_SRAM_0) then
                        sel_vec <= SEL_SRAM_0;
                     else
                        sel_vec <= SEL_SRAM_1;
                     end if;
                     
                  when CMD_ID =>
                     if(cmd2 = CMD_ID_SLOT) then
                        sel_vec <= SEL_SLOT_ID;
                     elsif(cmd2 = CMD_ID_ARRAY) then
                        sel_vec <= SEL_ARRAY_ID;
                     elsif(cmd2 = CMD_ID_SERIAL) then
                        sel_vec <= SEL_CARD_ID;
                     end if;
                     
                  when others =>
                     -- must not be implemented yet!
                     sel_vec <= (others => '0');
                     cmd_state <= CMD_WAIT;
               end case;
               
            when CMD_EXECUTE =>
               -- wait for thet test to complete
               if (done_vec /= DONE_NULL) then
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
