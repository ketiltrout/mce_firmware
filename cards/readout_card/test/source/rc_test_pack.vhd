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
-- rc_test_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for test module for readout card
-- 
-- Revision History:
--
-- $Log: rc_test_pack.vhd,v $
-- Revision 1.3  2004/06/11 21:15:02  erniel
-- initial version
--
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package rc_test_pack is

   constant LOGIC_0 : std_logic := '0';
   constant LOGIC_1 : std_logic := '1';
   
   ------------------------------------------------------------------
   --
   -- Command Declarations
   --
   ------------------------------------------------------------------

   -- One character commands ------------------------------------------
      
   constant CMD_RESET    : std_logic_vector(7 downto 0) := conv_std_logic_vector(27,8);    -- Esc
   constant CMD_DEBUG    : std_logic_vector(7 downto 0) := conv_std_logic_vector(68,8);    -- D
                                                                                                              
   -- Two character commands ------------------------------------------

   constant CMD_TX       : std_logic_vector(7 downto 0) := conv_std_logic_vector(116,8);   -- t                                  
   constant CMD_RX       : std_logic_vector(7 downto 0) := conv_std_logic_vector(114,8);   -- r
   
   constant CMD_TX_A     : std_logic_vector(7 downto 0) := conv_std_logic_vector(97,8);    -- a
   constant CMD_TX_B     : std_logic_vector(7 downto 0) := conv_std_logic_vector(98,8);    -- b
   constant CMD_RX_CMD   : std_logic_vector(7 downto 0) := conv_std_logic_vector(99,8);    -- c
   constant CMD_RX_SYNC  : std_logic_vector(7 downto 0) := conv_std_logic_vector(121,8);   -- y
   constant CMD_RX_SPARE : std_logic_vector(7 downto 0) := conv_std_logic_vector(112,8);   -- p

   -- Three character commands ----------------------------------------
   
   constant CMD_SERIALDAC   : std_logic_vector(7 downto 0) := conv_std_logic_vector(115,8);  -- s
   constant CMD_PARALLELDAC : std_logic_vector(7 downto 0) := conv_std_logic_vector(112,8);  -- p  
   
   constant CMD_DAC_RAMP    : std_logic_vector(7 downto 0) := conv_std_logic_vector(114,8);  -- r
   constant CMD_DAC_FIXED   : std_logic_vector(7 downto 0) := conv_std_logic_vector(102,8);  -- f
   constant CMD_DAC_CROSS   : std_logic_vector(7 downto 0) := conv_std_logic_vector(99,8);   -- c
   
   constant CMD_DAC_EVEN    : std_logic_vector(7 downto 0) := conv_std_logic_vector(101,8);  -- e
   constant CMD_DAC_ODD     : std_logic_vector(7 downto 0) := conv_std_logic_vector(111,8);  -- o
      
   ------------------------------------------------------------------
   --
   -- Component Declarations
   --
   ------------------------------------------------------------------
                                                                     
   -- reset state
   component rc_test_reset
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
   component rc_test_idle
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
   -- async modules
   
   component async_rx
      port(
         rx_i    : in std_logic;   -- receiver input pin
         valid_o  : out std_logic;  -- receiver data ready flag
         error_o : out std_logic;  -- receiver error flag
   
         -- Wishbone signals
         clk_i   : in std_logic;   -- 8x receive bit rate
         rst_i   : in std_logic;
         dat_o   : out std_logic_vector (7 downto 0);
         we_i    : in std_logic;
         stb_i   : in std_logic;
         ack_o   : out std_logic;
         cyc_i   : in std_logic
      );
   end component;

   component async_tx
      port(
         tx_o    : out std_logic;  -- transmitter output pin
         busy_o  : out std_logic;  -- transmitter busy flag
   
         -- Wishbone signals
         clk_i   : in std_logic;   -- 8x transmit bit rate
         rst_i   : in std_logic;
         dat_i   : in std_logic_vector (7 downto 0);
         we_i    : in std_logic;
         stb_i   : in std_logic;
         ack_o   : out std_logic;
         cyc_i   : in std_logic
      );
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

   ------------------------------------------------------------------
   -- RS232 transmit (debug)
      
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

end rc_test_pack;