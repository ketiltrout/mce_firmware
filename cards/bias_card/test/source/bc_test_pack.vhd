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
-- bc_test_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for test module for bias card
-- 
-- Revision History:
--
-- $Log: bc_test_pack.vhd,v $
-- Revision 1.2  2004/05/12 16:49:07  erniel
-- removed components already in all_test
--
-- Revision 1.1  2004/05/11 23:04:40  mandana
-- initial release - copied from all_test
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package bc_test_pack is

   ------------------------------------------------------------------
   --
   -- Command Declarations
   --
   ------------------------------------------------------------------

   -- One character commands ------------------------------------------
      
   constant CMD_RESET    : std_logic_vector(7 downto 0) := conv_std_logic_vector(27,8);    -- Esc
   constant CMD_TX       : std_logic_vector(7 downto 0) := conv_std_logic_vector(116,8);   -- t  
   constant CMD_BC_DAC   : std_logic_vector(7 downto 0) := conv_std_logic_vector(98,8);    -- b
   constant CMD_DEBUG    : std_logic_vector(7 downto 0) := conv_std_logic_vector(68,8);    -- D
   
                                                                                                              
   -- Two character commands ------------------------------------------

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
  
  ------------------------------------------------------------------
   -- BC DAC CTRL
  
  component dac_ctrl_test_wrapper
     port (
        -- basic signals
          rst_i     : in std_logic;    -- reset input
          clk_i     : in std_logic;    -- clock input
          en_i      : in std_logic;    -- enable signal
          done_o    : out std_logic;   -- done ouput signal
          
          -- transmitter signals removed!
          
          -- extended signals
          dac_dat_o : out std_logic_vector (31 downto 0); 
          dac_ncs_o : out std_logic_vector (31 downto 0); 
          dac_clk_o : out std_logic_vector (31 downto 0);
          
          dac_nclr_o: out std_logic;
          
          lvds_dac_dat_o : out std_logic;
          lvds_dac_ncs_o : out std_logic;
          lvds_dac_clk_o : out std_logic
          );   
  end component;  
  

end bc_test_pack;
