-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
-- 
--
--
-- Project:      Scuba 2
-- Author:       Bryce Burger
-- Organisation: UBC
-- original source: tb_clk_card
-- revised by:   Mandana Amiri
--
-- Title
-- tb_clk_bias_card
--
-- Description:
-- taken from 
-- Revision history:
-- <date $Date: 2004/12/16 23:29:24 $>    - <initials $Author: bench2 $>
-- $Log: tb_clk_bias_card.vhd,v $
-- Revision 1.2  2004/12/16 23:29:24  bench2
-- Mandana: added led tests for bias card
--
-- Revision 1.1  2004/12/16 18:17:06  bench2
-- Mandana: testbench to test bias_card through clk_card
--   
--
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.issue_reply_pack.all;
use work.sync_gen_core_pack.all;
use work.sync_gen_pack.all;
use work.dispatch_pack.all;
use work.ac_dac_ctrl_wbs_pack.all;
use work.ac_dac_ctrl_pack.all;
use work.bc_dac_ctrl_pack.all;
use work.frame_timing_core_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;
use work.clk_card_pack.all;
use work.bias_card_pack.all;
use work.addr_card_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

entity tb_clk_bias_card is     
end tb_clk_bias_card;

architecture tb of tb_clk_bias_card is 
 
--   signal rst_i                : std_logic := '0';
   
   -- simulation signals
   signal clk          : std_logic := '0';
   signal mem_clk      : std_logic := '0';
   signal comm_clk     : std_logic := '0';      
   signal fibre_clk    : std_logic := '0';
   signal fibre_tx_clk : std_logic := '0';
   signal fibre_rx_clk : std_logic := '0';
   signal lvds_clk_i   : std_logic := '0'; 
   constant clk_period          : TIME := 20 ns;    -- 50Mhz clock
   constant comm_clk_period     : TIME := 5 ns;
   constant mem_clk_period      : TIME := 5 ns;
   constant fibre_clk_period    : TIME := 40 ns;
--   constant fibre_tx_clk_period : TIME := 40 ns;  
--   constant fibre_rx_clk_period : TIME := 40 ns;  
--   constant lvds_clk_period     : TIME := 40 ns;
     
   constant pci_dsp_dly         : TIME := 160 ns ;   -- delay between tranmission of 4byte packets from PCI 
   constant fibre_clkr_prd      : TIME := 40 ns;   -- 25MHz clock
   
   constant preamble1          : std_logic_vector(7 downto 0)  := X"A5";
   constant preamble2          : std_logic_vector(7 downto 0)  := X"5A";
   constant command_wb         : std_logic_vector(31 downto 0) := X"20205742";
   constant command_rb         : std_logic_vector(31 downto 0) := x"20205242";
   constant command_go         : std_logic_vector(31 downto 0) := X"2020474F";
   constant command_st         : std_logic_vector(31 downto 0) := x"20205354";
   constant command_rs         : std_logic_vector(31 downto 0) := x"20205253";
   signal address_id           : std_logic_vector(31 downto 0) := X"00000000";--X"0002015C";
   
   signal ret_dat_s_stop       : std_logic_vector(31 downto 0) := X"00000011";   
   
--   constant ret_dat_cmd        : std_logic_vector(31 downto 0) := x"00" & ALL_READOUT_CARDS  & x"00" & RET_DAT_ADDR;
--   constant ret_dat_s_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD         & x"00" & RET_DAT_S_ADDR;
   constant ret_dat_cmd        : std_logic_vector(31 downto 0) := X"000B0030";  -- card id=4, ret_dat command
   constant ret_dat_s_cmd      : std_logic_vector(31 downto 0) := X"00020034";  -- card id=0, ret_dat_s command

   constant flux_fdbck_cmd     : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1        & x"00" & FLUX_FB_ADDR;
   constant bias_cmd           : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1        & x"00" & BIAS_ADDR;
   constant led_cmd            : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1        & x"00" & LED_ADDR;
   constant sram1_strt_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD         & x"00" & SRAM1_STRT_ADDR;
   constant on_bias_cmd        : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ON_BIAS_ADDR;
   constant off_bias_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & OFF_BIAS_ADDR;
   constant row_order_cmd      : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ROW_ORDER_ADDR;
   constant enbl_mux_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ENBL_MUX_ADDR;
   constant use_dv_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD         & x"00" & USE_DV_ADDR;
  
   constant data_block         : positive := 58;
   
   signal checksum             : std_logic_vector(31 downto 0) := X"00000000";
   signal command              : std_logic_vector(31 downto 0);   
   signal data_valid           : std_logic_vector(31 downto 0); -- used to be set to constant X"00000028"
   signal data                 : std_logic_vector(31 downto 0) := X"00000001";--integer := 1;
      
   ------------------------------------------------
   -- Clock Card Signals
   -------------------------------------------------
   -- PLL input:
   signal inclk      : std_logic := '0';
   signal rst_n      : std_logic := '1';
   
   -- LVDS interface:
   signal lvds_cmd   : std_logic;
   signal lvds_sync  : std_logic;
   signal lvds_spare : std_logic;
   signal lvds_clk   : std_logic;
   signal lvds_reply_ac_a : std_logic := '0';  
   signal lvds_reply_ac_b : std_logic := '0';
   signal lvds_reply_bc1_a : std_logic := '0';
   signal lvds_reply_bc1_b : std_logic := '0';
   signal lvds_reply_bc2_a : std_logic := '0';
   signal lvds_reply_bc2_b : std_logic := '0';
   signal lvds_reply_bc3_a : std_logic := '0';
   signal lvds_reply_bc3_b : std_logic := '0';
   signal lvds_reply_rc1_a : std_logic := '0';
   signal lvds_reply_rc1_b : std_logic := '0';
   signal lvds_reply_rc2_a : std_logic := '0';
   signal lvds_reply_rc2_b : std_logic := '0';
   signal lvds_reply_rc3_a : std_logic := '0'; 
   signal lvds_reply_rc3_b : std_logic := '0';  
   signal lvds_reply_rc4_a : std_logic := '0'; 
   signal lvds_reply_rc4_b : std_logic := '0';
   
   -- DV interface:
   signal dv_pulse_fibre  : std_logic := '0';
   signal dv_pulse_bnc    : std_logic := '0';
   
   -- eeprom interface:
   signal eeprom_si  : std_logic := '0';
   signal eeprom_so  : std_logic;
   signal eeprom_sck : std_logic;
   signal eeprom_cs  : std_logic;
   
   -- miscellaneous ports:
   signal red_led    : std_logic;
   signal ylw_led    : std_logic;
   signal grn_led    : std_logic;
   signal dip_sw3    : std_logic := '0';
   signal dip_sw4    : std_logic := '0';
   signal wdog       : std_logic;
   signal cc_slot_id    : std_logic_vector(3 downto 0) := "1000";
   
   -- debug ports:
   signal mictor_o    : std_logic_vector(15 downto 1);
   signal mictorclk_o : std_logic;
   signal mictor_e    : std_logic_vector(15 downto 1);
   signal mictorclk_e : std_logic;
   signal rs232_rx    : std_logic := '0';
   signal rs232_tx    : std_logic;
   
   -- interface to HOTLINK fibre receiver      
   signal fibre_rx_data      : std_logic_vector (7 downto 0);  
   signal fibre_rx_rdy       : std_logic;                      
   signal fibre_rx_rvs       : std_logic;                      
   signal fibre_rx_status    : std_logic;                      
   signal fibre_rx_sc_nd     : std_logic;                      
   signal fibre_rx_ckr       : std_logic := '0';                      
   
   -- interface to hotlink fibre transmitter      
   signal fibre_tx_data      : std_logic_vector (7 downto 0);
   signal fibre_tx_ena       : std_logic;  
   signal fibre_tx_sc_nd     : std_logic;

   ------------------------------------------------
   -- Address Card Signals
   -------------------------------------------------
   -- TTL interface:
   signal ttl_nrx    : std_logic_vector(3 downto 1);
   signal ttl_tx     : std_logic_vector(3 downto 1);
   signal ttl_txena  : std_logic_vector(3 downto 1);
    
   -- eeprom interface:
   signal ac_eeprom_si  : std_logic;
   signal ac_eeprom_so  : std_logic;
   signal ac_eeprom_sck : std_logic;
   signal ac_eeprom_cs  : std_logic;
    
   -- dac interface:
   signal dac_data0  : std_logic_vector(13 downto 0);
   signal dac_data1  : std_logic_vector(13 downto 0);
   signal dac_data2  : std_logic_vector(13 downto 0);
   signal dac_data3  : std_logic_vector(13 downto 0);
   signal dac_data4  : std_logic_vector(13 downto 0);
   signal dac_data5  : std_logic_vector(13 downto 0);
   signal dac_data6  : std_logic_vector(13 downto 0);
   signal dac_data7  : std_logic_vector(13 downto 0);
   signal dac_data8  : std_logic_vector(13 downto 0);
   signal dac_data9  : std_logic_vector(13 downto 0);
   signal dac_data10 : std_logic_vector(13 downto 0);
   signal dac_clk    : std_logic_vector(40 downto 0);
    
   -- miscellaneous ports:
   signal ac_red_led    : std_logic;
   signal ac_ylw_led    : std_logic;
   signal ac_grn_led    : std_logic;
   signal ac_dip_sw3    : std_logic;
   signal ac_dip_sw4    : std_logic;
   signal ac_wdog       : std_logic;
   signal ac_slot_id    : std_logic_vector(3 downto 0);
    
   -- debug ports:
   signal test       : std_logic_vector(16 downto 3);
   signal mictor     : std_logic_vector(32 downto 1);
   signal mictorclk  : std_logic_vector(2 downto 1);
   signal ac_rs232_rx: std_logic;
   signal ac_rs232_tx: std_logic;   
   
   ------------------------------------------------
   -- Bias Card Signals
   -------------------------------------------------    
   -- eeprom interface:
   signal bc_eeprom_si  : std_logic;
   signal bc_eeprom_so  : std_logic;
   signal bc_eeprom_sck : std_logic;
   signal bc_eeprom_cs  : std_logic;
    
   -- dac interface:
   signal dac_ncs       : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal dac_sclk      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal dac_data      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
   signal lvds_dac_ncs  : std_logic;
   signal lvds_dac_sclk : std_logic;
   signal lvds_dac_data : std_logic;
   signal dac_nclr      : std_logic; -- add to tcl file
   
   -- miscellaneous ports:
   signal bc_red_led    : std_logic;
   signal bc_ylw_led    : std_logic;
   signal bc_grn_led    : std_logic;
   signal bc_dip_sw3    : std_logic;
   signal bc_dip_sw4    : std_logic;
   signal bc_wdog       : std_logic;
   signal bc_slot_id    : std_logic_vector(3 downto 0) := "1110";
    
   -- debug ports:
--   signal test       : std_logic_vector(16 downto 3);
--   signal mictor     : std_logic_vector(32 downto 1);
--   signal mictorclk  : std_logic_vector(2 downto 1);
   signal bc_rs232_rx: std_logic;
   signal bc_rs232_tx: std_logic;   
   
   
begin
--   rst_n <= not rst_i;
   
   i_clk_card : clk_card
      port map
      (
       
         -- PLL input:
         inclk            => inclk,
         rst_n            => rst_n,
                          
         -- LVDS interface:
         lvds_cmd         => lvds_cmd,  
         lvds_sync        => lvds_sync, 
         lvds_spare       => lvds_spare,
         lvds_clk         => lvds_clk,  
         lvds_reply_ac_a  => lvds_reply_ac_a, 
         lvds_reply_ac_b  => lvds_reply_ac_b, 
         lvds_reply_bc1_a => lvds_reply_bc1_a,
         lvds_reply_bc1_b => lvds_reply_bc1_b,
         lvds_reply_bc2_a => lvds_reply_bc2_a,
         lvds_reply_bc2_b => lvds_reply_bc2_b,
         lvds_reply_bc3_a => lvds_reply_bc3_a,
         lvds_reply_bc3_b => lvds_reply_bc3_b,
         lvds_reply_rc1_a => lvds_reply_rc1_a,
         lvds_reply_rc1_b => lvds_reply_rc1_b,
         lvds_reply_rc2_a => lvds_reply_rc2_a,
         lvds_reply_rc2_b => lvds_reply_rc2_b,
         lvds_reply_rc3_a => lvds_reply_rc3_a,
         lvds_reply_rc3_b => lvds_reply_rc3_b,
         lvds_reply_rc4_a => lvds_reply_rc4_a,
         lvds_reply_rc4_b => lvds_reply_rc4_b,
                          
         -- DV interface:
         dv_pulse_fibre   => dv_pulse_fibre,
         dv_pulse_bnc     => dv_pulse_bnc,  
                          
         -- eeprom interface:
         eeprom_si        => eeprom_si,
         eeprom_so        => eeprom_so, 
         eeprom_sck       => eeprom_sck,
         eeprom_cs        => eeprom_cs, 
                          
         -- miscellaneous ports:
         red_led          => red_led,
         ylw_led          => ylw_led,
         grn_led          => grn_led,
         dip_sw3          => dip_sw3,
         dip_sw4          => dip_sw4,
         wdog             => wdog,  
         slot_id          => cc_slot_id,
                          
         -- debug ports:  
         mictor_o         => mictor_o,   
         mictorclk_o      => mictorclk_o,
         mictor_e         => mictor_e,   
         mictorclk_e      => mictorclk_e,
         rs232_rx         => rs232_rx,
         rs232_tx         => rs232_tx,
         
         -- interface to HOTLINK fibre receiver         
         fibre_rx_clk     => fibre_rx_clk,
         fibre_rx_data    => fibre_rx_data,   
         fibre_rx_rdy     => fibre_rx_rdy,    
         fibre_rx_rvs     => fibre_rx_rvs,    
         fibre_rx_status  => fibre_rx_status, 
         fibre_rx_sc_nd   => fibre_rx_sc_nd,  
         fibre_rx_ckr     => fibre_rx_ckr,    
         
         -- interface to hotlink fibre transmitter         
         fibre_tx_clk     => fibre_tx_clk,
         fibre_tx_data    => fibre_tx_data,   
         fibre_tx_ena     => fibre_tx_ena,    
         fibre_tx_sc_nd   => fibre_tx_sc_nd  
      );
   i_bias_card: bias_card
      port map(

         -- PLL input:
         inclk      => lvds_clk,
         rst_n      => rst_n,
         
         -- LVDS interface:
         lvds_cmd   => lvds_cmd,  
         lvds_sync  => lvds_sync, 
         lvds_spare => lvds_spare,
         lvds_txa   => lvds_reply_bc1_a, 
         lvds_txb   => lvds_reply_bc1_b, 
         
         -- TTL interface:
         ttl_nrx    => ttl_nrx,  
         ttl_tx     => ttl_tx,   
         ttl_txena  => ttl_txena,
         
         -- eeprom ice:nterface:
         eeprom_si  => bc_eeprom_si, 
         eeprom_so  => bc_eeprom_so, 
         eeprom_sck => bc_eeprom_sck,
         eeprom_cs  => bc_eeprom_cs, 
         
         -- dac interface:
         dac_ncs    => dac_ncs,      
         dac_sclk   => dac_sclk,     
         dac_data   => dac_data,         
         lvds_dac_ncs  => lvds_dac_ncs, 
         lvds_dac_sclk => lvds_dac_sclk,
         lvds_dac_data => lvds_dac_data,
         dac_nclr      => dac_nclr,     
         
         -- miscellaneous ports:
         red_led    => bc_red_led, 
         ylw_led    => bc_ylw_led, 
         grn_led    => bc_grn_led, 
         dip_sw3    => bc_dip_sw3, 
         dip_sw4    => bc_dip_sw4, 
         wdog       => bc_wdog,    
         slot_id    => bc_slot_id, 
         
         -- debug ports:
         test       => test,       
         mictor     => mictor,     
         mictorclk  => mictorclk,  
         rs232_rx   => bc_rs232_rx,
         rs232_tx   => bc_rs232_tx
      );     
   
--   i_addr_card : addr_card
--      port map(
--         -- simulation signals
--         clk              => clk,         
--         mem_clk          => mem_clk,     
--         comm_clk         => comm_clk,       
--   
--         -- PLL input:
--         inclk            => inclk,
--         rst_n            => rst_n,
--         
--         -- LVDS interface:
--         lvds_cmd         => lvds_cmd,  
--         lvds_sync        => lvds_sync, 
--         lvds_spare       => lvds_spare,
--         lvds_txa         => lvds_reply_ac_a, 
--         lvds_txb         => lvds_reply_ac_b, 
--         
--         -- TTL interface:
--         ttl_nrx          => ttl_nrx,  
--         ttl_tx           => ttl_tx,   
--         ttl_txena        => ttl_txena,
--         
--         -- eeprom interface:
--         eeprom_si        => ac_eeprom_si, 
--         eeprom_so        => ac_eeprom_so, 
--         eeprom_sck       => ac_eeprom_sck,
--         eeprom_cs        => ac_eeprom_cs, 
--         
--         -- dac interface:
--         dac_data0        => dac_data0,  
--         dac_data1        => dac_data1,  
--         dac_data2        => dac_data2,  
--         dac_data3        => dac_data3,  
--         dac_data4        => dac_data4,  
--         dac_data5        => dac_data5,  
--         dac_data6        => dac_data6,  
--         dac_data7        => dac_data7,  
--         dac_data8        => dac_data8,  
--         dac_data9        => dac_data9,  
--         dac_data10       => dac_data10, 
--         dac_clk          => dac_clk,    
--         
--         -- miscellaneous ports:
--         red_led          => ac_red_led, 
--         ylw_led          => ac_ylw_led, 
--         grn_led          => ac_grn_led, 
--         dip_sw3          => ac_dip_sw3, 
--         dip_sw4          => ac_dip_sw4, 
--         wdog             => ac_wdog,    
--         slot_id          => ac_slot_id, 
--         
--         -- debug ports:
--         test             => test,       
--         mictor           => mictor,     
--         mictorclk        => mictorclk,  
--         rs232_rx         => ac_rs232_rx,
--         rs232_tx         => ac_rs232_tx
--   );
   
   -- set up hotlink receiver signals 
   fibre_rx_rvs    <= '0';  -- no violation
   fibre_rx_status <= '1';  -- status ok
   fibre_rx_sc_nd  <= '0';  -- data     
   bc_slot_id      <= "1110";
   cc_slot_id      <= "1000";
   ------------------------------------------------
   -- Create test bench clock
   -------------------------------------------------
   inclk        <= not inclk        after clk_period/2;
--   clk          <= not clk          after clk_period/2;
--   comm_clk     <= not comm_clk     after comm_clk_period/2;
--   mem_clk      <= not mem_clk      after mem_clk_period/2;
--   fibre_clk    <= not fibre_clk    after fibre_clk_period/2;
--   fibre_tx_clk <= not fibre_tx_clk after fibre_tx_clk_period/2;
--   fibre_rx_clk <= not fibre_rx_clk after fibre_rx_clk_period/2;
--   lvds_clk_i   <= not lvds_clk_i   after lvds_clk_period/2;
   fibre_rx_ckr <= not fibre_rx_ckr after fibre_clk_period/2;
   
   ------------------------------------------------
   -- Create test bench stimuli
   -------------------------------------------------
   
   stimuli : process

   procedure do_reset is
   begin
      rst_n <= '0';
      wait for clk_period*5 ;
      rst_n <= '1';
      wait for clk_period*5 ;   
      assert false report " Resetting the DUT." severity NOTE;
   end do_reset;
   --------------------------------------------------
  
   procedure load_preamble is
   begin
   
   for I in 0 to 3 loop
      fibre_rx_rdy    <= '1';  -- data not ready (active low)
      fibre_rx_data  <= preamble1;
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;   
   
   for I in 0 to 3 loop
      fibre_rx_rdy    <= '1';  -- data not ready (active low)
      fibre_rx_data  <= preamble2;
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;     
   
   fibre_rx_rdy <= '1';
   wait for pci_dsp_dly;     
    
   assert false report "preamble OK" severity NOTE;
   end load_preamble;
   
   ---------------------------------------------------------    
 
   procedure load_command is 
   begin   
      checksum  <= command;
    
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= command(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
    
      assert false report "command code loaded" severity NOTE;
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly;   
     
      -- load up address_id
      checksum <= checksum XOR address_id;
     
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data   <= address_id(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
     
      assert false report "address id loaded" severity NOTE;
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly; 
     
      -- load up data valid       
      checksum <= checksum XOR data_valid;
  
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= data_valid(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      assert false report "data valid loaded" severity NOTE;
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly; 
      
      -- load up data block
      -- first load valid data
      for I in 0 to (To_integer((Unsigned(data_valid)))-1) loop
      --for I in 0 to (data_valid-1) loop
         
         fibre_rx_rdy   <= '1';
         
         fibre_rx_data <= data(7 downto 0);
         checksum (7 downto 0) <= checksum (7 downto 0) XOR data(7 downto 0);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         
         fibre_rx_data <= data(15 downto 8);
         checksum (15 downto 8) <= checksum (15 downto 8) XOR data(15 downto 8);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';

         fibre_rx_data <= data(23 downto 16);
         checksum (23 downto 16) <= checksum (23 downto 16) XOR data(23 downto 16);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         
         fibre_rx_data <= data(31 downto 24);
         checksum (31 downto 24) <= checksum (31 downto 24) XOR data(31 downto 24);
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         
         case address_id is
            when ret_dat_s_cmd => data <= ret_dat_s_stop;
            when ret_dat_cmd   => data <= (others => '0');
            when others        => data <= data + 1;
         end case;
         
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy <= '1';
         wait for pci_dsp_dly;        
      end loop;
    
      for J in (To_integer((Unsigned(data_valid)))) to data_block-1 loop
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         fibre_rx_rdy   <= '1';
         fibre_rx_data <= X"00";
         wait for fibre_clkr_prd * 0.4;
         fibre_rx_rdy   <= '0';
         wait for fibre_clkr_prd * 0.6;
            
         fibre_rx_rdy <= '1';
         wait for pci_dsp_dly; 
      end loop;
        
      assert false report "data words loaded to memory...." severity NOTE;

   end load_command;
    
   ------------------------------------------------------

   procedure load_checksum is
    
      begin 
         
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      fibre_rx_rdy   <= '1';
      fibre_rx_data <= checksum(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      fibre_rx_rdy   <= '0';
      wait for fibre_clkr_prd * 0.6;
         
      assert false report "checksum loaded...." severity NOTE;  
       
      fibre_rx_rdy <= '1';
      wait for pci_dsp_dly; 
   
   end load_checksum;
       
  
--------------------------------------------------------
-- Begin Test
------------------------------------------------------      
       
   begin
      
      do_reset;    
      
 --     command <= command_wb;
 --     address_id <= use_dv_cmd;
 --     data_valid <= X"00000001";
 --     data       <= X"00000001";
 --     load_preamble;
 --     load_command;
 --     load_checksum;
 --     
 --     wait for 50 us;
 --     
 --     command <= command_rb;
 --     address_id <= use_dv_cmd;
 --     data_valid <= X"00000001";
 --     data       <= X"00000000";
 --     load_preamble;
 --     load_command;
 --     load_checksum;
 --     
 --     wait for 50 us;
 --     
 --     command <= command_go;
 --     address_id <= use_dv_cmd;
 --     data_valid <= X"00000001";
 --     data       <= X"00000000";
 --     load_preamble;
 --     load_command;
 --     load_checksum;
 --     
 --     wait for 50 us;
 --
--      command <= command_st;
--      address_id <= use_dv_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 50 us;
--      
--      command <= command_rs;
--      address_id <= use_dv_cmd;
--      data_valid <= X"00000001";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 50 us;
----------------------------------------------------------
-- bc_dac_ctrl commands
------------------------------------------------------      
      -- turn LEDs off
--      command <= command_wb;
--      address_id <= led_cmd;
--      data_valid <= X"00000001"; --1 values
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
      
--      wait for 50 us;
--      
--      -- turn LEDs on
--      command <= command_wb;
--      address_id <= led_cmd;
--      data_valid <= X"00000001"; --1 values
--      data       <= X"00000007";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 50 us;
--      
--      -- load values to 32 flux DACs
      command <= command_wb;
      address_id <= flux_fdbck_cmd;
      data_valid <= X"00000020"; --32 values
      data       <= X"55AA55AA";
      load_preamble;
      load_command;
      load_checksum;
      
      wait for 50 us;

     -- read back 32 flux DACs values
     command <= command_rb;
     address_id <= flux_fdbck_cmd;
     data_valid <= X"00000020";
     data       <= X"00000000";
     load_preamble;
     load_command;
     load_checksum;
     
--     wait for 50 us;

      --load values to the single Bias DAC
--      command <= command_wb;
--      address_id <= bias_cmd;
--      data_valid <= X"00000001"; --1 value
--      data       <= X"00000021";
--      load_preamble;
--      load_command;
--      load_checksum;
      
--      wait for 50 us;

--      command <= command_wb;
--      address_id <= flux_fdbck_cmd;
--      data_valid <= X"00000020"; --32 values
--      data       <= X"88888888";
--      load_preamble;
--      load_command;
--      load_checksum;
      
      wait for 150 us;
 
--------------------------------------------------------
-- ac_dac_ctrl commands
------------------------------------------------------      
      
     -- This is a 'WB ac on_bias 0 1 2 .. 40' command
     -- This command should excercise the Address Card's wbs_ac_dac_ctrl block
--     command <= command_wb;
--     address_id <= on_bias_cmd;
--     data_valid <= X"00000029"; --41 values
--     data       <= X"00000000";
--     load_preamble;
--     load_command;
--     load_checksum;
     
--     wait for 300 us;
--
--      -- This is a 'WB ac on_bias 0 1 2 .. 40' command
--      -- This command should excercise the Address Card's wbs_ac_dac_ctrl block
--      command <= command_rb;
--      address_id <= on_bias_cmd;
--      data_valid <= X"00000029"; --41 values
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 400 us;
--
--      -- This is a 'WB ac on_bias 0 1 2 .. 40' command
--      -- This command should excercise the Address Card's wbs_ac_dac_ctrl block
--      command <= command_wb;
--      address_id <= row_order_cmd;
--      data_valid <= X"00000029"; --41 values
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 200 us;
--
--      command <= command_wb;
--      address_id <= enbl_mux_cmd;
--      data_valid <= X"00000001"; --1 value
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 120 us;
--
--      command <= command_wb;
--      address_id <= enbl_mux_cmd;
--      data_valid <= X"00000001"; --1 value
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 120 us;
--
--      command <= command_wb;
--      address_id <= enbl_mux_cmd;
--      data_valid <= X"00000001"; --1 value
--      data       <= X"00000001";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 400 us;

      assert false report "Simulation done." severity FAILURE;
   end process stimuli;   
end tb;