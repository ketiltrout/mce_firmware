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
-- $Log: cc_test_pack.vhd,v $
-- Revision 1.3  2006/09/08 20:25:51  mandana
-- added fo_bist and sram_test, integrated with Rev. 2 cc_test
--
-- Revision 1.2  2004/07/02 17:20:37  mandana
-- Mandana: walking 0/1 tests combined
--
-- Revision 1.1  2004/06/09 22:13:38  erniel
-- initial version
--
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package cc_test_pack is
   
   constant MANCH_WIDTH    : integer := 24;
   -- pll output allocation:
   --    c0 = FPGA system clock (50MHz)
   --    c1 = 180deg phase shift of system clock (50MHz)
   --    c2 = Asynchronous Transfer clock (100MHz)
   --    c3 = fibre clock (25MHz)
   --    e0 = fibre transmit clock
   --    e1 = fibre rx refclk
   --    e2 = Backplane lvds clock
   
   component cc_test_pll
   port(
      inclk0 : in std_logic;    
      c0     : out std_logic;
      c1     : out std_logic;
      c2     : out std_logic;
      c3     : out std_logic;
      e0     : out std_logic;
      e1     : out std_logic;
      e2     : out std_logic
   );
   end component;

   
   ------------------------------------------------------------------
   -- fibre test
    
   ------------------------------------------------------------------
   component fo_bist 
   port(
        rst_i    : in std_logic;
        clk_i    : in std_logic;
        clk_n_i  : in std_logic;
        en_i     : in std_logic;
        done_o   : out std_logic;
        
        -- fibre pins
        fibre_tx_data_o   : out std_logic_vector(7 downto 0);
        fibre_tx_clkW_o   : out std_logic;
        fibre_tx_ena_o    : out std_logic;
        fibre_tx_rp_o     : in std_logic;
        fibre_tx_sc_nd_o  : out std_logic;
        fibre_tx_enn_o    : out std_logic;
        -- fibre_tx_svs is tied to gnd on board
        -- fibre_tx_enn is tied to vcc on board
        -- fibre_tx_mode is tied to gnd on board
        fibre_tx_foto_o   : out std_logic;
        fibre_tx_bisten_o : out std_logic;
        
        fibre_rx_data_i   : in std_logic_vector(7 downto 0);
        --fibre_rx_refclk : out std_logic;
        fibre_rx_clkr_i   : in std_logic;
        fibre_rx_error_i  : in std_logic;
        fibre_rx_rdy_i    : in std_logic;
        fibre_rx_status_i : in std_logic;
        fibre_rx_sc_nd_i  : in std_logic;
        fibre_rx_rvs_i    : in std_logic;
        fibre_rx_rf_o     : out std_logic; --  is tied to vcc on board, we lifted the pin and routed it to P10.22
        fibre_rx_a_nb_o   : out std_logic;
        fibre_rx_bisten_o : out std_logic;
        
        rx_data1_o        : out std_logic_vector(7 downto 0);
        rx_data2_o        : out std_logic_vector(7 downto 0);
        rx_data3_o        : out std_logic_vector(7 downto 0);
        
        --test pins
        mictor_o : out std_logic_vector(12 downto 0)
        );
   end component;

  
   ------------------------------------------------------------------
   -- SRAM
   component sram_test
   port( 
        rst_i  : in std_logic;    
        clk_i  : in std_logic;    
        en_i   : in std_logic;    
        done_o : out std_logic;   
         
        -- RS232 signals
         
        -- physical pins
        addr_o  : out std_logic_vector(19 downto 0);
        data_bi : inout std_logic_vector(15 downto 0); 
        n_ble_o : out std_logic;
        n_bhe_o : out std_logic;
        n_oe_o  : out std_logic;
        n_ce1_o : out std_logic;
        ce2_o   : out std_logic;
        n_we_o  : out std_logic;
--        idx_o   : out integer;-- to pass error address bit
        pass_o  : out std_logic;
        fail_o  : out std_logic);
   end component;

   ------------------------------------------------------------------
   -- dv_rx   
   component dv_rx_test
   port(
         -- Clock and Reset:
         clk_i               : in std_logic;
         clk_n_i             : in std_logic;
         rst_i               : in std_logic;
         en_i                : in std_logic;
         done_o              : out std_logic;
         
         -- Fibre Interface:
         manch_det_i         : in std_logic;
         manch_dat_i         : in std_logic;
         dv_dat_i            : in std_logic;
         
         -- Test output
         dat_o               : out std_logic_vector (23 downto 0)      
   );     
   end component;

end cc_test_pack;
