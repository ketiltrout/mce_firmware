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
-- Revision 1.2  2004/05/03 02:59:56  erniel
-- added DIP commands
--
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

   ------------------------------------------------------------------
   --
   -- Command Declarations
   --
   ------------------------------------------------------------------

   -- One character commands ------------------------------------------
      
   constant CMD_RESET    : std_logic_vector(7 downto 0) := conv_std_logic_vector(27,8);    -- Esc
   constant CMD_DIP      : std_logic_vector(7 downto 0) := conv_std_logic_vector(100,8);   -- d                                 
   constant CMD_WATCHDOG : std_logic_vector(7 downto 0) := conv_std_logic_vector(119,8);   -- w  
   constant CMD_TX       : std_logic_vector(7 downto 0) := conv_std_logic_vector(116,8);   -- t                                                     
   constant CMD_SLOT_ID  : std_logic_vector(7 downto 0) := conv_std_logic_vector(115,8);   -- s        
   constant CMD_CARD_ID  : std_logic_vector(7 downto 0) := conv_std_logic_vector(99,8);    -- c
   
   constant CMD_DEBUG    : std_logic_vector(7 downto 0) := conv_std_logic_vector(68,8);    -- D
   
                                                                                                              
   -- Two character commands ------------------------------------------
                                 
   constant CMD_LED      : std_logic_vector(7 downto 0) := conv_std_logic_vector(108,8);   -- l
   constant CMD_LED_1    : std_logic_vector(7 downto 0) := conv_std_logic_vector(49,8);    -- 1
   constant CMD_LED_2    : std_logic_vector(7 downto 0) := conv_std_logic_vector(50,8);    -- 2
   constant CMD_LED_3    : std_logic_vector(7 downto 0) := conv_std_logic_vector(51,8);    -- 3
   
   constant CMD_RX       : std_logic_vector(7 downto 0) := conv_std_logic_vector(114,8);   -- r
   constant CMD_RX_CLK   : std_logic_vector(7 downto 0) := conv_std_logic_vector(49,8);    -- 1    
   constant CMD_RX_CMD   : std_logic_vector(7 downto 0) := conv_std_logic_vector(50,8);    -- 2
   constant CMD_RX_SYNC  : std_logic_vector(7 downto 0) := conv_std_logic_vector(51,8);    -- 3
   constant CMD_RX_SPARE : std_logic_vector(7 downto 0) := conv_std_logic_vector(52,8);    -- 4

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
           dip_switch_i : in std_logic_vector (1 downto 0));
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
   
   ------------------------------------------------------------------
   -- LVDS transmit
   
   component lvds_tx_test_wrapper
      port(rst_i : in std_logic;   -- reset input
           clk_i : in std_logic;   -- clock input
           en_i : in std_logic;    -- enable signal
           done_o : out std_logic; -- done ouput signal
      
           -- extended signals
           lvds_o : out std_logic);
   end component;
   
   ------------------------------------------------------------------
   -- LVDS receive
   
   component lvds_rx_test_wrapper
      port(rst_i : in std_logic;   -- reset input
           clk_i : in std_logic;   -- clock input
           en_i : in std_logic;    -- enable signal
           done_o : out std_logic; -- done ouput signal
      
           -- transmitter signals
           tx_busy_i : in std_logic;  -- transmit busy flag
           tx_ack_i : in std_logic;   -- transmit ack
           tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
           tx_we_o : out std_logic;   -- transmit write flag
           tx_stb_o : out std_logic;  -- transmit strobe flag
      
           -- extended signals
           lvds_i : in std_logic);
   end component;
   
   component rs232_data_tx
      generic(WIDTH : in integer range 4 to 1024 := 8);
      port(clk_i   : in std_logic;
           rst_i   : in std_logic;
           data_i  : in std_logic_vector(WIDTH-1 downto 0);
           start_i : in std_logic;
           done_o  : out std_logic;

           tx_busy_i : in std_logic;
           tx_ack_i  : in std_logic;
           tx_data_o : out std_logic_vector(7 downto 0);
           tx_we_o   : out std_logic;
           tx_stb_o  : out std_logic);
  end component;
  
end all_test_pack;
