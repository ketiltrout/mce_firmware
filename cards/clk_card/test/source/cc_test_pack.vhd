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
-- $Log$
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.array_id_pack.all;

package cc_test_pack is

   constant LOGIC_0 : std_logic := '0';
   constant LOGIC_1 : std_logic := '1';
   
   ------------------------------------------------------------------
   --
   -- Command Declarations
   --
   ------------------------------------------------------------------

   -- One character commands ------------------------------------------
      
   constant CMD_RESET      : std_logic_vector(7 downto 0) := conv_std_logic_vector(27,8);    -- Esc
   constant CMD_BOX_ID     : std_logic_vector(7 downto 0) := conv_std_logic_vector(98,8);    -- b                                                                                     
   constant CMD_ARRAY_ID   : std_logic_vector(7 downto 0) := conv_std_logic_vector(97,8);    -- a
   constant CMD_EEPROM     : std_logic_vector(7 downto 0) := conv_std_logic_vector(101,8);   -- e
   
   constant CMD_DEBUG      : std_logic_vector(7 downto 0) := conv_std_logic_vector(68,8);    -- D
   
                                                                                                              
   -- Two character commands ------------------------------------------
   
   constant CMD_TX         : std_logic_vector(7 downto 0) := conv_std_logic_vector(116,8);   -- t 
   constant CMD_TX_CMD     : std_logic_vector(7 downto 0) := conv_std_logic_vector(99,8);    -- c
   constant CMD_TX_SYNC    : std_logic_vector(7 downto 0) := conv_std_logic_vector(121,8);   -- y
   constant CMD_TX_SPARE   : std_logic_vector(7 downto 0) := conv_std_logic_vector(112,8);   -- p                                  
   
   constant CMD_SRAM       : std_logic_vector(7 downto 0) := conv_std_logic_vector(115,8);   -- s
   constant CMD_SRAM_1     : std_logic_vector(7 downto 0) := conv_std_logic_vector(49,8);    -- 1
   constant CMD_SRAM_2     : std_logic_vector(7 downto 0) := conv_std_logic_vector(50,8);    -- 2
   
   constant CMD_FIBRE      : std_logic_vector(7 downto 0) := conv_std_logic_vector(102,8);   -- f
   constant CMD_FIBRE_BIST : std_logic_vector(7 downto 0) := conv_std_logic_vector(98,8);    -- b
   constant CMD_FIBRE_TX   : std_logic_vector(7 downto 0) := conv_std_logic_vector(116,8);   -- t
   constant CMD_FIBRE_RX   : std_logic_vector(7 downto 0) := conv_std_logic_vector(114,8);   -- r
   
   -- Three character commands ------------------------------------------
   
   constant CMD_RX         : std_logic_vector(7 downto 0) := conv_std_logic_vector(114,8);   -- r
   constant CMD_RX_0       : std_logic_vector(7 downto 0) := conv_std_logic_vector(48,8);    -- 0
   constant CMD_RX_1       : std_logic_vector(7 downto 0) := conv_std_logic_vector(49,8);    -- 1
   constant CMD_RX_2       : std_logic_vector(7 downto 0) := conv_std_logic_vector(50,8);    -- 2 
   constant CMD_RX_3       : std_logic_vector(7 downto 0) := conv_std_logic_vector(51,8);    -- 3 
   constant CMD_RX_4       : std_logic_vector(7 downto 0) := conv_std_logic_vector(52,8);    -- 4
   constant CMD_RX_5       : std_logic_vector(7 downto 0) := conv_std_logic_vector(53,8);    -- 5
   constant CMD_RX_6       : std_logic_vector(7 downto 0) := conv_std_logic_vector(54,8);    -- 6
   constant CMD_RX_7       : std_logic_vector(7 downto 0) := conv_std_logic_vector(55,8);    -- 7
   constant CMD_RX_A       : std_logic_vector(7 downto 0) := conv_std_logic_vector(97,8);    -- a
   constant CMD_RX_B       : std_logic_vector(7 downto 0) := conv_std_logic_vector(98,8);    -- b
      
   ------------------------------------------------------------------
   --
   -- Component Declarations
   --
   ------------------------------------------------------------------
                                                                     
   -- reset state
   component cc_test_reset
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
   component cc_test_idle
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
         cmd3_o : out std_logic_vector(7 downto 0); -- command char 3
         
         -- receiver signals
         rx_valid_i : in std_logic;  -- receive data flag
         rx_ack_i : in std_logic;   -- receive ack
         rx_stb_o : out std_logic;  -- receive strobe
         rx_data_i : in std_logic_vector(7 downto 0) -- receive data
      );
   end component;
   
   ------------------------------------------------------------------
   -- LVDS transmit
   
   ------------------------------------------------------------------
   -- LVDS receive
   
   ------------------------------------------------------------------
   -- fibre transmit
   
   ------------------------------------------------------------------
   -- fibre receive
   
   ------------------------------------------------------------------
   -- RS232 transmit
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
  
   ------------------------------------------------------------------
   -- Box ID
   
   ------------------------------------------------------------------
   -- Array ID
   
   component array_id_test_wrapper 
   port(rst_i     : in std_logic;    -- reset input
        clk_i     : in std_logic;    -- clock input
        en_i      : in std_logic;    -- enable signal
        done_o    : out std_logic;   -- done ouput signal
      
        tx_busy_i : in std_logic;    -- transmit busy flag
        tx_ack_i  : in std_logic;    -- transmit ack
        tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
        tx_we_o   : out std_logic;   -- transmit write flag
        tx_stb_o  : out std_logic;   -- transmit strobe flag
  
        array_id_i : in std_logic_vector (ARRAY_ID_BITS-1 downto 0));
   end component;
   
   ------------------------------------------------------------------
   -- SRAM
   
   ------------------------------------------------------------------
   -- EEPROM   
   
end cc_test_pack;
