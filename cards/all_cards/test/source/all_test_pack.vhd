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
-- State interface package.
-- 
-- Revision History:
--
-- $Log$
--
-- Dec 22, 2003: Initial version - NRG
-- Feb 25, 2004: Added serial port command constants - NRG
-- Feb 29, 2004: Added s_led. - NRG
-- Mar 01, 2004: Added CMD_LED_3 - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.slot_id_pack.all;
use work.array_id_pack.all;

package all_test_pack is

   -- define serial port command characters
   
   -- single character commands -------------------------------------
   constant CMD_RESET : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(114,8); -- r
   constant CMD_STATUS : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(83,8);  -- S
   constant CMD_WATCHDOG : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(87,8);  -- W
   constant CMD_JTAG : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(74,8); --  J
   constant CMD_EEPROM : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(69,8);  -- E
   constant CMD_TEMP : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(116,8); -- t
   
   -- 2 character commands ------------------------------------------
   -- ID commands - first byte
   constant CMD_ID : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(73,8);  -- I
   -- ID commands - second byte
   constant CMD_ID_SLOT : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(83,8);  -- S
   constant CMD_ID_SERIAL : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(78,8);  -- N
   constant CMD_ID_ARRAY : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(65,8);  -- A
   constant CMD_ID_BOX : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(66,8);  -- B
                              
   -- receiver commands - first byte
   constant CMD_RX : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(82,8);  -- R
   -- RX commands - second byte
   constant CMD_RX_0 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(48,8);  -- 0
   constant CMD_RX_1 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(49,8);  -- 1
   constant CMD_RX_2 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(50,8);  -- 2
   constant CMD_RX_3 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(51,8);  -- 3
   constant CMD_RX_4 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(52,8);  -- 4
   constant CMD_RX_5 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(53,8);  -- 5
   constant CMD_RX_6 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(54,8);  -- 6
   constant CMD_RX_7 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(55,8);  -- 7
                                 
   -- transmitter commands - first byte
   constant CMD_TX : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(84,8);  -- T
   -- TX commands - second byte
   constant CMD_TX_0 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(48,8);  -- 0
   constant CMD_TX_1 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(49,8);  -- 1
   constant CMD_TX_2 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(50,8);  -- 2

--   -- fibre optic commands - first byte
--   constant CMD_FIBRE : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(70,8);  -- F
--   -- fibre optic commands - second byte
--   constant CMD_FIBRE_READ : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(82,8);  -- R
--   constant CMD_FIBRE_WRITE : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(87,8);  -- W
--   constant CMD_FIBRE_FLAG : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(70,8);  -- F
                              
   -- LED commands - first byte
   constant CMD_LED : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(76,8);  -- L
   -- LED commands - second byte
--   constant CMD_LED_0 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(48,8);  -- 0
   constant CMD_LED_1 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(49,8);  -- 1
   constant CMD_LED_2 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(50,8);  -- 2
   constant CMD_LED_3 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(51,8);  -- 3
                              
--   -- SRAM commands - first byte
--   constant CMD_SRAM : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(77,8);  -- M
--   -- SRAM commands - second byte
--   constant CMD_SRAM_0 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(48,8);  -- 0
--   constant CMD_SRAM_1 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(49,8);  -- 1
   
--   -- power supply commands - first byte
--   constant CMD_POWER : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(80,8);  -- P
--   -- power supply commands - second byte
--   constant CMD_POWER_READ : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(82,8);  -- R
--   constant CMD_POWER_WRITE : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(87,8);  -- W
   
   ------------------------------------------------------------------
   -- reset state
   component all_test_reset
      port (
         -- basic signals
         rst_i : in std_logic;   -- reset input
         clk_i : in std_logic;   -- clock input
         en_i : in std_logic;    -- enable signal
         done_o : out std_logic; -- done output signal
         
         -- transmitter signals
         tx_busy_i : in std_logic;  -- transmit busy flag
         tx_ack_i : in std_logic;   -- transmit ack
         tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
         tx_we_o : out std_logic;   -- transmit write flag
         tx_stb_o : out std_logic   -- transmit strobe flag
      );
   end component;
   
   ------------------------------------------------------------------   
   -- idle state
   component all_test_idle
      port (
         -- basic signals
         rst_i : in std_logic;   -- reset input
         clk_i : in std_logic;   -- clock input
         en_i : in std_logic;    -- enable signal
         done_o : out std_logic; -- done output signal
         
         -- transmitter signals
         tx_busy_i : in std_logic;  -- transmit busy flag
         tx_ack_i : in std_logic;   -- transmit ack
         tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
         tx_we_o : out std_logic;   -- transmit write flag
         tx_stb_o : out std_logic;   -- transmit strobe flag
         
         -- extended signals
         cmd1_o : out std_logic_vector(7 downto 0); -- command char 1
         cmd2_o : out std_logic_vector(7 downto 0); -- command char 2
         
         -- receiver signals
         rx_valid_i : in std_logic;  -- receive data flag
         rx_ack_i : in std_logic;   -- receive ack
         rx_stb_o : out std_logic;  -- receive strobe
         rx_data_i : in std_logic_vector(7 downto 0) -- receive data
      );
   end component;
   
   ------------------------------------------------------------------
   -- led state
   component led_test_wrapper
      port (
         -- basic signals
         rst_i : in std_logic;   -- reset input
         clk_i : in std_logic;   -- clock input
         en_i : in std_logic;    -- enable signal
         done_o : out std_logic; -- done output signal
         
--         -- transmitter signals
--         tx_busy_i : in std_logic;  -- transmit busy flag
--         tx_ack_i : in std_logic;   -- transmit ack
--         tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
--         tx_we_o : out std_logic;   -- transmit write flag
--         tx_stb_o : out std_logic;  -- transmit strobe flag
         
         -- extended signals
         led_o : out std_logic      -- physical LED pin
      );
   end component;
   
   ------------------------------------------------------------------
   -- watchdog state
   component watchdog_test_wrapper
      port (
         -- basic signals
         rst_i : in std_logic;   -- reset input
         clk_i : in std_logic;   -- clock input
         en_i : in std_logic;    -- enable signal
         done_o : out std_logic; -- done output signal
         
--         -- transmitter signals
--         tx_busy_i : in std_logic;  -- transmit busy flag
--         tx_ack_i : in std_logic;   -- transmit ack
--         tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
--         tx_we_o : out std_logic;   -- transmit write flag
--         tx_stb_o : out std_logic;  -- transmit strobe flag
         
         -- extended signals
         wdt_o : out std_logic      -- physical Watchdog pin
      );
   end component;

   ------------------------------------------------------------------
   -- LVDS TX state
   component lvds_tx_test_wrapper
      port (
         -- basic signals
         rst_i : in std_logic;   -- reset input
         clk_i : in std_logic;   -- clock input
         en_i : in std_logic;    -- enable signal
         done_o : out std_logic; -- done output signal
         
--         -- transmitter signals
--         tx_busy_i : in std_logic;  -- transmit busy flag
--         tx_ack_i : in std_logic;   -- transmit ack
--         tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
--         tx_we_o : out std_logic;   -- transmit write flag
--         tx_stb_o : out std_logic;  -- transmit strobe flag
         
         -- extended signals
         lvds_o : out std_logic   -- LVDS output bit
      );
   end component;
   
--   ------------------------------------------------------------------
--   -- SRAM verification
--   component sram_test_wrapper
--      port(rst_i  : in std_logic;    
--           clk_i  : in std_logic;    
--           en_i   : in std_logic;    
--           done_o : out std_logic;   
--      
--           -- RS232 signals
--           tx_busy_i : in std_logic;
--           tx_ack_i  : in std_logic;
--           tx_data_o : out std_logic_vector(7 downto 0);
--           tx_we_o   : out std_logic; 
--           tx_stb_o  : out std_logic; 
--      
--           -- physical pins
--           addr_o  : out std_logic_vector(19 downto 0);
--           data_bi : inout std_logic_vector(15 downto 0); 
--           n_ble_o : out std_logic;
--           n_bhe_o : out std_logic;
--           n_oe_o  : out std_logic;
--           n_ce1_o : out std_logic;
--           ce2_o   : out std_logic;
--           n_we_o  : out std_logic);
--   end component;
   
   ------------------------------------------------------------------
   -- slot ID
   component slot_id_test_wrapper
      port(rst_i     : in std_logic;    -- reset input
           clk_i     : in std_logic;    -- clock input
           en_i      : in std_logic;    -- enable signal
           done_o    : out std_logic;   -- done ouput signal
      
           -- transmitter signals
           tx_busy_i : in std_logic;    -- transmit busy flag
           tx_ack_i  : in std_logic;    -- transmit ack
           tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
           tx_we_o   : out std_logic;   -- transmit write flag
           tx_stb_o  : out std_logic;   -- transmit strobe flag
      
           -- extended signals
           slot_id_i : in std_logic_vector (SLOT_ID_BITS-1 downto 0));
   end component;
   
   ------------------------------------------------------------------
   -- card ID
   component card_id_test_wrapper
      port(rst_i     : in std_logic;    -- reset input
           clk_i     : in std_logic;    -- clock input
           en_i      : in std_logic;    -- enable signal
           done_o    : out std_logic;   -- done ouput signal
      
           -- transmitter signals
           tx_busy_i : in std_logic;    -- transmit busy flag
           tx_ack_i  : in std_logic;    -- transmit ack
           tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
           tx_we_o   : out std_logic;   -- transmit write flag
           tx_stb_o  : out std_logic;   -- transmit strobe flag
      
           -- extended signals
           data_bi   : inout std_logic);
   end component;

   ------------------------------------------------------------------
   -- array ID
   component array_id_test_wrapper
      port(rst_i     : in std_logic;    -- reset input
           clk_i     : in std_logic;    -- clock input
           en_i      : in std_logic;    -- enable signal
           done_o    : out std_logic;   -- done ouput signal
      
           -- transmitter signals
           tx_busy_i : in std_logic;    -- transmit busy flag
           tx_ack_i  : in std_logic;    -- transmit ack
           tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
           tx_we_o   : out std_logic;   -- transmit write flag
           tx_stb_o  : out std_logic;   -- transmit strobe flag
      
           -- extended signals
           array_id_i : in std_logic_vector (ARRAY_ID_BITS-1 downto 0));
   end component;
   
      
end all_test_pack;
