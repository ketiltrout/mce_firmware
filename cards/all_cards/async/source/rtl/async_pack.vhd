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
-- Author:              Neil Gruending (last modified by Ernie Lin)
-- Organisation:        UBC Physics and Astronomy
--
-- Description:
-- Asynchronous transmitter/receiver package.
-- 
-- Revision History:
--
-- $Log: async_pack.vhd,v $
-- Revision 1.2  2004/06/29 21:24:28  erniel
-- removed obsolete modules
-- added LVDS transmit/receive
-- added RS232 transmit/receive
--
--
-- Dec 22, 2003: Initial version - NRG
-- Feb 28, 2004: Updated to reflect modified async_mux. - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package async_pack is

   ---------------------------------------------------------
   -- Core asynchronous modules
   
   component async_tx
   port(tx_clk_i : in std_logic;   -- 25 MHz for LVDS, 115.2 kHz for RS232
        rst_i    : in std_logic;

        dat_i    : in std_logic_vector (7 downto 0);
        stb_i    : in std_logic;
        tx_o     : out std_logic;
        busy_o   : out std_logic);
   end component;

   component async_rx
   port(rx_clk_i : in std_logic;   -- 200 MHz for LVDS, 921.6 kHz for RS232
        rst_i    : in std_logic;
     
        dat_o    : out std_logic_vector (7 downto 0);
        stb_i    : in std_logic;
        rx_i     : in std_logic;
        valid_o  : out std_logic;
        error_o  : out std_logic);
   end component;


   ---------------------------------------------------------
   -- LVDS wrapper modules
   
   component lvds_tx
   port(clk_i      : in std_logic;
        comm_clk_i : in std_logic;
        rst_i      : in std_logic;
     
        dat_i      : in std_logic_vector(31 downto 0);
        start_i    : in std_logic;
        done_o     : out std_logic;
     
        lvds_o     : out std_logic);
   end component;

   component lvds_rx
   port(clk_i      : in std_logic;
        comm_clk_i : in std_logic;
        rst_i      : in std_logic;
     
        dat_o      : out std_logic_vector(31 downto 0);
        rdy_o      : out std_logic;
        ack_i      : in std_logic;
     
        lvds_i     : in std_logic);
   end component;


   ---------------------------------------------------------
   -- RS232 wrapper modules
   
   component rs232_tx
   port(clk_i      : in std_logic;
        comm_clk_i : in std_logic;
        rst_i      : in std_logic;
     
        dat_i      : in std_logic_vector(7 downto 0);
        start_i    : in std_logic;
        done_o     : out std_logic;
     
        rs232_o    : out std_logic);
   end component;

   component rs232_rx
   port(clk_i      : in std_logic;
        comm_clk_i : in std_logic;
        rst_i      : in std_logic;
     
        dat_o      : out std_logic_vector(7 downto 0);
        rdy_o      : out std_logic;
        ack_i      : in std_logic;
     
        rs232_i    : in std_logic);
   end component;

end async_pack;
