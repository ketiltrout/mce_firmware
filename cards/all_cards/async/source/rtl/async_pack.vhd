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
-- $Log$
--
-- Dec 22, 2003: Initial version - NRG
-- Feb 28, 2004: Updated to reflect modified async_mux. - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package async_pack is

--   -- How many states do we have?
--   
--   -- tx_t is used by async_mux to multiplex multiple modules
--   -- to async_tx
--   type tx_t is record
--      dat : std_logic_vector(7 downto 0);
--      we : std_logic;
--      stb : std_logic;
--   end record;
--   
--   -- tx_array is used by async_mux as inputs to the multiplexer
--   type tx_array is array (natural range <>) of tx_t;
--
--   component async_rx
--      port(
--         rx_i    : in std_logic;   -- receiver input pin
--         flag_o  : out std_logic;  -- receiver data ready flag
--         error_o : out std_logic;  -- receiver error flag
--   
--         -- Wishbone signals
--         clk_i   : in std_logic;   -- 8x receive bit rate
--         rst_i   : in std_logic;
--         dat_o   : out std_logic_vector (7 downto 0);
--         we_i    : in std_logic;
--         stb_i   : in std_logic;
--         ack_o   : out std_logic;
--         cyc_i   : in std_logic
--      );
--   end component;
--
--   component async_tx
--      port(
--         tx_o    : out std_logic;  -- transmitter output pin
--         busy_o  : out std_logic;  -- transmitter busy flag
--   
--         -- Wishbone signals
--         clk_i   : in std_logic;   -- 8x transmit bit rate
--         rst_i   : in std_logic;
--         dat_i   : in std_logic_vector (7 downto 0);
--         we_i    : in std_logic;
--         stb_i   : in std_logic;
--         ack_o   : out std_logic;
--         cyc_i   : in std_logic
--      );
--   end component;
--   
--   component async_clk
--      port(
--         clk_i : in std_logic;   -- 25MHz input clock
--         rst_i : in std_logic;   -- reset input
--         txclk_o : out std_logic;   -- 57.6 kHz output
--         rxclk_o : out std_logic   -- 462 kHz output
--      );
--   end component;
--   
--   component async_mux
--      generic (
--         size : integer := 1 -- how many items we have in the mux input
--      );
--      port(
--         rst_i : in std_logic;
--         clk_i : in std_logic;
--         sel_i : in std_logic_vector(size - 1 downto 0);  -- mux xelect
--         in_i : in tx_array(size - 1 downto 0);  -- mux inputs
--         out_o : out tx_t      -- mux outputs
--      );
--   end component;

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
