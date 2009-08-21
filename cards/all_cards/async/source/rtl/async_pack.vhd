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
-- Revision 1.8  2005/01/12 22:49:25  erniel
-- updated lvds_rx component
--
-- Revision 1.7  2005/01/11 19:37:15  erniel
-- updated component declarations
--
-- Revision 1.6  2004/12/14 23:01:42  erniel
-- updated lvds_tx declaration
-- updated rs232_tx declaration
--
-- Revision 1.5  2004/09/02 19:11:58  bburger
-- Bryce:  updated the lvds_tx interface to match that in lvds_tx.vhd
--
-- Revision 1.4  2004/06/30 01:46:13  erniel
-- removed async_tx declaration
-- removed async_rx declaration
--
-- Revision 1.3  2004/06/29 21:30:04  erniel
-- removed old async declarations
-- removed old tx_t declaration
--
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

   --
   -- Notes:
   -- 
   -- clk_i       is the system clock (50 MHz)
   --
   -- comm_clk_i  is the base clock from which the transmit and
   --             receive clocks are derived (200 MHz)
   --

   ---------------------------------------------------------
   -- LVDS wrapper modules
   
   component lvds_tx
   port(clk_i      : in std_logic;
        rst_i      : in std_logic;
     
        dat_i      : in std_logic_vector(31 downto 0);
        rdy_i      : in std_logic;
        busy_o     : out std_logic;
     
        lvds_o     : out std_logic);
   end component;

   component lvds_rx
   generic (
     FPGA_DEVICE_FAMILY : string);
   port(comm_clk_i : in std_logic;
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
        rst_i      : in std_logic;
     
        dat_i      : in std_logic_vector(7 downto 0);
        rdy_i    : in std_logic;
        busy_o     : out std_logic;
     
        rs232_o    : out std_logic);
   end component;

   component rs232_rx
   port(clk_i      : in std_logic;
        rst_i      : in std_logic;
     
        dat_o      : out std_logic_vector(7 downto 0);
        rdy_o      : out std_logic;
        ack_i      : in std_logic;
     
        rs232_i    : in std_logic);
   end component;

end async_pack;
