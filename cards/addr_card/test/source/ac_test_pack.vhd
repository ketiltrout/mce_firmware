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
-- ac_test_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for test module for Address card
-- 
-- Revision History:
-- <date $Date: 2004/05/17 19:09:08 $>	- <initials $Author: erniel $>
-- $Log: ac_test_pack.vhd,v $
-- Revision 1.5  2004/05/17 19:09:08  erniel
-- expanded dac_dat_o into 11 separate 14-bit vectors
--
-- Revision 1.4  2004/05/17 00:49:52  erniel
-- changed LVDS tx test to two character command
-- modified command encoding
--
-- Revision 1.3  2004/05/13 17:44:06  mandana
-- modified all_test for ac_test
--
--
---------------------------------------------------------------------

library ieee ,sys_param;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use sys_param.data_types_pack.all;

package ac_test_pack is

   ------------------------------------------------------------------
   --
   -- Command Declarations
   --
   ------------------------------------------------------------------

   -- One character commands ------------------------------------------
      
   constant CMD_RESET    : std_logic_vector(7 downto 0) := conv_std_logic_vector(27,8);    -- Esc                                                  
   constant CMD_DAC_FIX  : std_logic_vector(7 downto 0) := conv_std_logic_vector(102,8);   -- f
   constant CMD_DAC_RAMP : std_logic_vector(7 downto 0) := conv_std_logic_vector(100,8);   -- d
   
   constant CMD_DEBUG    : std_logic_vector(7 downto 0) := conv_std_logic_vector(68,8);    -- D
                                                                                                                 
   -- Two character commands ------------------------------------------
   
   constant CMD_TX       : std_logic_vector(7 downto 0) := conv_std_logic_vector(116,8);   -- t                                  
   constant CMD_TX_A     : std_logic_vector(7 downto 0) := conv_std_logic_vector(97,8);    -- a
   constant CMD_TX_B     : std_logic_vector(7 downto 0) := conv_std_logic_vector(98,8);    -- b
   constant CMD_RX       : std_logic_vector(7 downto 0) := conv_std_logic_vector(114,8);   -- r 
   constant CMD_RX_CMD   : std_logic_vector(7 downto 0) := conv_std_logic_vector(99,8);    -- c
   constant CMD_RX_SYNC  : std_logic_vector(7 downto 0) := conv_std_logic_vector(121,8);   -- y
   constant CMD_RX_SPARE : std_logic_vector(7 downto 0) := conv_std_logic_vector(112,8);   -- p

   ------------------------------------------------------------------
   --
   -- Component Declarations
   --
   ------------------------------------------------------------------
                                                                     
   -- reset state
   component ac_test_reset
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
   component ac_test_idle
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
    --       rx_clk_i : in std_logic;
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
   -- DAC tests
   
   component ac_dac_ramp
      port(rst_i       : in std_logic ;
           clk_i       : in std_logic ;
           en_i        : in std_logic ;
           done_o      : out std_logic ;
           
--           dac_dat_o   : out w_array11; 
           dac_dat0_o  : out std_logic_vector(13 downto 0);
           dac_dat1_o  : out std_logic_vector(13 downto 0);
           dac_dat2_o  : out std_logic_vector(13 downto 0);
           dac_dat3_o  : out std_logic_vector(13 downto 0);
           dac_dat4_o  : out std_logic_vector(13 downto 0);
           dac_dat5_o  : out std_logic_vector(13 downto 0);
           dac_dat6_o  : out std_logic_vector(13 downto 0);
           dac_dat7_o  : out std_logic_vector(13 downto 0);
           dac_dat8_o  : out std_logic_vector(13 downto 0);
           dac_dat9_o  : out std_logic_vector(13 downto 0);
           dac_dat10_o : out std_logic_vector(13 downto 0);
      
           dac_clk_o   : out std_logic_vector (40 downto 0));
   end component;
 
   component ac_dac_ctrl_test
      port(rst_i       : in std_logic ;
           clk_i       : in std_logic ;
           en_i        : in std_logic ;
           done_o      : out std_logic ;
           
--           dac_dat_o   : out w_array11; 
           dac_dat0_o  : out std_logic_vector(13 downto 0);
           dac_dat1_o  : out std_logic_vector(13 downto 0);
           dac_dat2_o  : out std_logic_vector(13 downto 0);
           dac_dat3_o  : out std_logic_vector(13 downto 0);
           dac_dat4_o  : out std_logic_vector(13 downto 0);
           dac_dat5_o  : out std_logic_vector(13 downto 0);
           dac_dat6_o  : out std_logic_vector(13 downto 0);
           dac_dat7_o  : out std_logic_vector(13 downto 0);
           dac_dat8_o  : out std_logic_vector(13 downto 0);
           dac_dat9_o  : out std_logic_vector(13 downto 0);
           dac_dat10_o : out std_logic_vector(13 downto 0);
           
           dac_clk_o   : out std_logic_vector (40 downto 0) );
   end component;
  
end ac_test_pack;
