-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- tb_sram_test.vhd
--

-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- testbench for the bc_sram_test, very simple: assert enable and wait for done!
--
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$
--  
-----------------------------------------------------------------------------
library IEEE, sys_param, components;
use IEEE.std_logic_1164.all;
use components.component_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.cc_test_pack.all;

entity tb_fo_bist is
end tb_fo_bist;

architecture beh of tb_fo_bist is

   constant PERIOD : time := 20 ns;

   signal rst : std_logic;
   signal clk : std_logic := '0';
   signal clk_n : std_logic := '1';
   signal ena : std_logic;
   signal done: std_logic;
   signal tx_data, rx_data : std_logic_vector(7 downto 0);
   signal tx_ena, tx_rp, tx_sc_nd, tx_enn, tx_foto, tx_bisten, rx_error, rx_rdy, rx_status, 
          rx_sc_nd, rx_rvs, rx_rf, rx_a_nb, rx_bisten : std_logic;
   
begin

   DUT :  fo_bist
      port map(
         rst_i    => rst,
         clk_i    => clk,
         clk_n_i  => clk_n,
         en_i     => ena,
         done_o   => done,
         
         -- fibre pins
         fibre_tx_data_o   => tx_data,
         fibre_tx_clkW_o   => open, --fibre_tx_clkW,
         fibre_tx_ena_o    => tx_ena, 
         fibre_tx_rp_o     => tx_rp,  
         fibre_tx_sc_nd_o  => tx_sc_nd,
         fibre_tx_enn_o    => tx_enn,
         -- fibre_tx_svs is tied to gnd on board
         -- fibre_tx_enn is tied to vcc on board
         -- fibre_tx_mode is tied to gnd on board
         fibre_tx_foto_o   => tx_foto,
         fibre_tx_bisten_o => tx_bisten,
         
         fibre_rx_data_i   => rx_data,
         --fibre_rx_refclk => --fibre_rx_refcl
         fibre_rx_error_i  => rx_error,
         fibre_rx_rdy_i    => rx_rdy,  
         fibre_rx_status_i => rx_status,
         fibre_rx_sc_nd_i  => rx_sc_nd,
         fibre_rx_rvs_i    => rx_rvs, 
         fibre_rx_rf_o     => rx_rf,   
         fibre_rx_a_nb_o   => rx_a_nb, 
         fibre_rx_bisten_o => rx_bisten,
             
         --test pins
         mictor_o => open
      );
   clk <= not clk after PERIOD/2;
   clk_n <= not clk;

   STIMULI : process
   begin
      ena       <= '0';
      rst       <= '0';
      wait for PERIOD;
      ena       <= '1';
      wait for PERIOD;
      rst       <= '0';     

      -- enable module
      ena       <= '1';     
--      wait for PERIOD*10;
--      data   <= (others => '0');
      wait until done = '1';
      ena       <= '0';
      wait for PERIOD*500;
      
      -- enable module
      ena       <= '1';
      wait until done = '1';
      ena       <= '0';
      wait for PERIOD*500;
      
      --enable module
      ena       <= '1';     
      wait until done = '1';
      ena        <= '0';
      wait for PERIOD*500;
      assert FALSE report "Simulation done." severity failure;    

   end process STIMULI;

end BEH;

configuration cfg_tb_fo_bist of tb_fo_bist is
   for BEH
   end for;
end cfg_tb_fo_bist;