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
-- all_test_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for test module for common items
-- 
-- Revision History:
--
-- $Log: all_test_pack.vhd,v $
-- Revision 1.1  2004/04/28 20:16:13  erniel
-- initial version
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.dip_switch_pack.all;
use work.slot_id_pack.all;
use work.array_id_pack.all;

package all_test_pack is

   -- define serial port command characters
   
   -- single character commands -------------------------------------
   
   constant CMD_RESET : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(114,8);   -- r
   constant CMD_HEADER : std_logic_vector(7 downto 0) :=
                              conv_std_logic_vector(72, 8);   -- H                               
   constant CMD_WATCHDOG : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(87,8);    -- W
                              
--   constant CMD_STATUS : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(83,8);    -- S                              
--   constant CMD_JTAG : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(74,8);    -- J
--   constant CMD_EEPROM : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(69,8);    -- E
--   constant CMD_TEMP : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(116,8);   -- t
--   constant CMD_DAC : std_logic_vector(7 downto 0) :=
--                              conv_std_logic_vector(100, 8);  -- d 



   -- 2 character commands ------------------------------------------

   ------------------------------------------------------------------
   --
   -- Serial Number commands
   --
   ------------------------------------------------------------------
      
   -- ID commands - first byte
   constant CMD_ID : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(73,8);  -- I
   -- ID commands - second byte
   constant CMD_ID_SLOT : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(83,8);  -- S
   constant CMD_ID_SERIAL : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(78,8);  -- N
--   constant CMD_ID_ARRAY : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(65,8);  -- A
--   constant CMD_ID_BOX : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(66,8);  -- B
                           
   
   ------------------------------------------------------------------
   --
   -- LVDS transmitter / Receiver commands
   --
   ------------------------------------------------------------------
   
--   -- receiver commands - first byte
--   constant CMD_RX : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(82,8);  -- R
--   -- RX commands - second byte
--   constant CMD_RX_0 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(48,8);  -- 0
--   constant CMD_RX_1 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(49,8);  -- 1
--   constant CMD_RX_2 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(50,8);  -- 2
--   constant CMD_RX_3 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(51,8);  -- 3
--   constant CMD_RX_4 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(52,8);  -- 4
--   constant CMD_RX_5 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(53,8);  -- 5
--   constant CMD_RX_6 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(54,8);  -- 6
--   constant CMD_RX_7 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(55,8);  -- 7
--   constant CMD_RX_8 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(56,8);  -- 8
--   constant CMD_RX_9 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(57,8);  -- 9
--   constant CMD_RX_10 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(65,8);  -- A
--   constant CMD_RX_11 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(66,8);  -- B
--   constant CMD_RX_12 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(67,8);  -- C
--   constant CMD_RX_13 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(68,8);  -- D
--   constant CMD_RX_14 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(69,8);  -- E
--   constant CMD_RX_15 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(70,8);  -- F   
--                                                           
--   -- transmitter commands - first byte
--   constant CMD_TX : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(84,8);  -- T
--   -- TX commands - second byte
--   constant CMD_TX_0 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(48,8);  -- 0
--   constant CMD_TX_1 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(49,8);  -- 1
--   constant CMD_TX_2 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(50,8);  -- 2
--   constant CMD_TX_3 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(51,8);  -- 3                              


   ------------------------------------------------------------------
   --
   -- Fibre transmitter / Receiver commands
   --
   ------------------------------------------------------------------
   
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

   ------------------------------------------------------------------
   --
   -- LED commands
   --
   ------------------------------------------------------------------
                                 
   -- LED commands - first byte
   constant CMD_LED : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(76,8);  -- L
   -- LED commands - second byte
   constant CMD_LED_1 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(49,8);  -- 1
   constant CMD_LED_2 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(50,8);  -- 2
   constant CMD_LED_3 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(51,8);  -- 3

   ------------------------------------------------------------------
   --
   -- Dip Switch commands
   --
   ------------------------------------------------------------------
   
   -- Dip Switch commands - first byte
   constant CMD_DIP : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(68, 8);  -- D
   -- Dip Switch commands - second byte
   constant CMD_DIP_1 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(49, 8);  -- 1
   constant CMD_DIP_2 : std_logic_vector(7 downto 0) := 
                              conv_std_logic_vector(50, 8);  -- 2                                                         
   ------------------------------------------------------------------
   --
   -- SRAM Verify commands
   --
   ------------------------------------------------------------------
                                 
--   -- SRAM commands - first byte
--   constant CMD_SRAM : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(77,8);  -- M
--   -- SRAM commands - second byte
--   constant CMD_SRAM_0 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(48,8);  -- 0
--   constant CMD_SRAM_1 : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(49,8);  -- 1

   ------------------------------------------------------------------
   --
   -- Power Supply commands
   --
   ------------------------------------------------------------------
      
--   -- power supply commands - first byte
--   constant CMD_POWER : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(80,8);  -- P
--   -- power supply commands - second byte
--   constant CMD_POWER_READ : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(82,8);  -- R
--   constant CMD_POWER_WRITE : std_logic_vector(7 downto 0) := 
--                              conv_std_logic_vector(87,8);  -- W
  
  

   ------------------------------------------------------------------
   --
   -- Component Declarations
   --
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
   -- LED
   component led_test_wrapper
      port (
         -- basic signals
         rst_i : in std_logic;   -- reset input
         clk_i : in std_logic;   -- clock input
         en_i : in std_logic;    -- enable signal
         done_o : out std_logic; -- done output signal
         
         -- extended signals
         led_o : out std_logic      -- physical LED pin
      );
   end component;
    
   ------------------------------------------------------------------
   -- DIP switches
   component dip_switch_test_wrapper
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
           dip_switch_i : in std_logic_vector (DIP_SWITCH_BITS-1 downto 0));
   end component;
   
   ------------------------------------------------------------------
   -- watchdog 
   component watchdog_test_wrapper
      port (
         -- basic signals
         rst_i : in std_logic;   -- reset input
         clk_i : in std_logic;   -- clock input
         en_i : in std_logic;    -- enable signal
         done_o : out std_logic; -- done output signal
         
         -- extended signals
         wdt_o : out std_logic      -- physical Watchdog pin
      );
   end component;
   
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
