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
-- tb1_readout_card
--
-- Project:	  SCUBA-2
-- Author:        Bryce Burger, Mohsen Nahvi, and Anthony Ko
-- Organisation:  UBC
--
-- 
-- Description:
-- 
-- This is a simple test bench for the readout card.  It instantiates the
-- readout card top level and the clk_card.  A few write and read commands are
-- then issued.
-- 
-- Revision history:
-- $Log: tb1_readout_card.vhd,v $
-- Revision 1.1  2004/12/10 18:53:29  mohsen
-- Initial Release
--
--
--
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.issue_reply_pack.all;
use work.async_pack.all;
use work.sync_gen_core_pack.all;
use work.sync_gen_pack.all;
use work.dispatch_pack.all;
use work.frame_timing_core_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;
use work.clk_card_pack.all;
use work.readout_card_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

entity tb1_readout_card is     
end tb1_readout_card;

architecture tb1 of tb1_readout_card is 



  component readout_card
    generic (
      CARD : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0));
    port (
      rst_n          : in  std_logic;
      inclk          : in  std_logic;
      adc1_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc2_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc3_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc4_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc5_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc6_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc7_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc8_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc1_ovr       : in  std_logic;
      adc2_ovr       : in  std_logic;
      adc3_ovr       : in  std_logic;
      adc4_ovr       : in  std_logic;
      adc5_ovr       : in  std_logic;
      adc6_ovr       : in  std_logic;
      adc7_ovr       : in  std_logic;
      adc8_ovr       : in  std_logic;
      adc1_rdy       : in  std_logic;
      adc2_rdy       : in  std_logic;
      adc3_rdy       : in  std_logic;
      adc4_rdy       : in  std_logic;
      adc5_rdy       : in  std_logic;
      adc6_rdy       : in  std_logic;
      adc7_rdy       : in  std_logic;
      adc8_rdy       : in  std_logic;
      adc1_clk       : out std_logic;
      adc2_clk       : out std_logic;
      adc3_clk       : out std_logic;
      adc4_clk       : out std_logic;
      adc5_clk       : out std_logic;
      adc6_clk       : out std_logic;
      adc7_clk       : out std_logic;
      adc8_clk       : out std_logic;
      dac_FB1_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB2_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB3_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB4_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB5_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB6_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB7_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB8_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_FB_clk     : out std_logic_vector(7 downto 0);
      dac_clk        : out std_logic_vector(7 downto 0);
      dac_dat        : out std_logic_vector(7 downto 0);
      bias_dac_ncs   : out std_logic_vector(7 downto 0);
      offset_dac_ncs : out std_logic_vector(7 downto 0);
      lvds_cmd       : in  std_logic;
      lvds_sync      : in  std_logic;
      lvds_spare     : in  std_logic;
      lvds_txa       : out std_logic;
      lvds_txb       : out std_logic;
      red_led        : out std_logic;
      ylw_led        : out std_logic;
      grn_led        : out std_logic;
      dip_sw3        : in  std_logic;
      dip_sw4        : in  std_logic;
      wdog           : out std_logic;
      slot_id        : in  std_logic_vector(3 downto 0);
      card_id        : in  std_logic;
      mictor         : out std_logic_vector(31 downto 0));
  end component;


  
  
   constant clk_period          : TIME := 40 ns;    -- 25Mhz clock
   constant comm_clk_period     : TIME := 5 ns;
   constant mem_clk_period      : TIME := 5 ns;
   constant fibre_clk_period    : TIME := 40 ns;
     
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
   constant sram1_strt_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD         & x"00" & SRAM1_STRT_ADDR;
   constant on_bias_cmd        : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ON_BIAS_ADDR;
   constant off_bias_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & OFF_BIAS_ADDR;
   constant row_order_cmd      : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ROW_ORDER_ADDR;
   constant enbl_mux_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ENBL_MUX_ADDR;
   constant use_dv_cmd         : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD         & x"00" & USE_DV_ADDR;
   constant gainp0_cmd         : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1     & x"00" & GAINP0_ADDR;
   constant sa_bias_cmd        : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1     & x"00" & SA_BIAS_ADDR;
   constant servo_mode_cmd     : std_logic_vector(31 downto 0) := x"00" & READOUT_CARD_1     & x"00" & SERVO_MODE_ADDR;
  
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
   signal slot_id    : std_logic_vector(3 downto 0) := "1111";
   
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




  -----------------------------------------------------------------------------
  -- Readout_card signals
  -----------------------------------------------------------------------------

--  signal rst_n_rc          : std_logic;
--  signal inclk_rc          : std_logic;
  signal adc1_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc2_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc3_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc4_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc5_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc6_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc7_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc8_dat_rc       : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc1_ovr_rc       : std_logic;
  signal adc2_ovr_rc       : std_logic;
  signal adc3_ovr_rc       : std_logic;
  signal adc4_ovr_rc       : std_logic;
  signal adc5_ovr_rc       : std_logic;
  signal adc6_ovr_rc       : std_logic;
  signal adc7_ovr_rc       : std_logic;
  signal adc8_ovr_rc       : std_logic;
  signal adc1_rdy_rc       : std_logic;
  signal adc2_rdy_rc       : std_logic;
  signal adc3_rdy_rc       : std_logic;
  signal adc4_rdy_rc       : std_logic;
  signal adc5_rdy_rc       : std_logic;
  signal adc6_rdy_rc       : std_logic;
  signal adc7_rdy_rc       : std_logic;
  signal adc8_rdy_rc       : std_logic;
  signal adc1_clk_rc       : std_logic;
  signal adc2_clk_rc       : std_logic;
  signal adc3_clk_rc       : std_logic;
  signal adc4_clk_rc       : std_logic;
  signal adc5_clk_rc       : std_logic;
  signal adc6_clk_rc       : std_logic;
  signal adc7_clk_rc       : std_logic;
  signal adc8_clk_rc       : std_logic;
  signal dac_FB1_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB2_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB3_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB4_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB5_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB6_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB7_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB8_dat_rc    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_FB_clk_rc     : std_logic_vector(7 downto 0);
  signal dac_clk_rc        : std_logic_vector(7 downto 0);
  signal dac_dat_rc        : std_logic_vector(7 downto 0);
  signal bias_dac_ncs_rc   : std_logic_vector(7 downto 0);
  signal offset_dac_ncs_rc : std_logic_vector(7 downto 0);
--  signal lvds_cmd_rc       : std_logic;
--  signal lvds_sync_rc      : std_logic;
--  signal lvds_spare_rc     : std_logic;
  signal lvds_txa_rc       : std_logic;
  signal lvds_txb_rc       : std_logic;
  signal red_led_rc        : std_logic;
  signal ylw_led_rc        : std_logic;
  signal grn_led_rc        : std_logic;
  signal dip_sw3_rc        : std_logic;
  signal dip_sw4_rc        : std_logic;
  signal wdog_rc           : std_logic;
  signal slot_id_rc        : std_logic_vector(3 downto 0);
  signal card_id_rc        : std_logic;
  signal mictor_rc         : std_logic_vector(31 downto 0);
  
begin

  -----------------------------------------------------------------------------
  -- Instantiate clk_card
  -----------------------------------------------------------------------------
   
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
         slot_id          => slot_id,
                          
         -- debug ports:  
         mictor_o         => mictor_o,   
         mictorclk_o      => mictorclk_o,
         mictor_e         => mictor_e,   
         mictorclk_e      => mictorclk_e,
         rs232_rx         => rs232_rx,
         rs232_tx         => rs232_tx,
         
         -- interface to HOTLINK fibre receiver         
         fibre_rx_clk     => open,
         fibre_rx_data    => fibre_rx_data,   
         fibre_rx_rdy     => fibre_rx_rdy,    
         fibre_rx_rvs     => fibre_rx_rvs,    
         fibre_rx_status  => fibre_rx_status, 
         fibre_rx_sc_nd   => fibre_rx_sc_nd,  
         fibre_rx_ckr     => fibre_rx_ckr,    
         
         -- interface to hotlink fibre transmitter         
         fibre_tx_clk     => open,
         fibre_tx_data    => fibre_tx_data,   
         fibre_tx_ena     => fibre_tx_ena,    
         fibre_tx_sc_nd   => fibre_tx_sc_nd  
      );
   

   ----------------------------------------------------------------------------
   -- Instantiate DUT
   ----------------------------------------------------------------------------

     i_readout_card: readout_card
       generic map (
           CARD => READOUT_CARD_1)
       port map (
           rst_n          => rst_n,
           inclk          => lvds_clk,
           adc1_dat       => adc1_dat_rc,
           adc2_dat       => adc2_dat_rc,
           adc3_dat       => adc3_dat_rc,
           adc4_dat       => adc4_dat_rc,
           adc5_dat       => adc5_dat_rc,
           adc6_dat       => adc6_dat_rc,
           adc7_dat       => adc7_dat_rc,
           adc8_dat       => adc8_dat_rc,
           adc1_ovr       => adc1_ovr_rc,
           adc2_ovr       => adc2_ovr_rc,
           adc3_ovr       => adc3_ovr_rc,
           adc4_ovr       => adc4_ovr_rc,
           adc5_ovr       => adc5_ovr_rc,
           adc6_ovr       => adc6_ovr_rc,
           adc7_ovr       => adc7_ovr_rc,
           adc8_ovr       => adc8_ovr_rc,
           adc1_rdy       => adc1_rdy_rc,
           adc2_rdy       => adc2_rdy_rc,
           adc3_rdy       => adc3_rdy_rc,
           adc4_rdy       => adc4_rdy_rc,
           adc5_rdy       => adc5_rdy_rc,
           adc6_rdy       => adc6_rdy_rc,
           adc7_rdy       => adc7_rdy_rc,
           adc8_rdy       => adc8_rdy_rc,
           adc1_clk       => adc1_clk_rc,
           adc2_clk       => adc2_clk_rc,
           adc3_clk       => adc3_clk_rc,
           adc4_clk       => adc4_clk_rc,
           adc5_clk       => adc5_clk_rc,
           adc6_clk       => adc6_clk_rc,
           adc7_clk       => adc7_clk_rc,
           adc8_clk       => adc8_clk_rc,
           dac_FB1_dat    => dac_FB1_dat_rc,
           dac_FB2_dat    => dac_FB2_dat_rc,
           dac_FB3_dat    => dac_FB3_dat_rc,
           dac_FB4_dat    => dac_FB4_dat_rc,
           dac_FB5_dat    => dac_FB5_dat_rc,
           dac_FB6_dat    => dac_FB6_dat_rc,
           dac_FB7_dat    => dac_FB7_dat_rc,
           dac_FB8_dat    => dac_FB8_dat_rc,
           dac_FB_clk     => dac_FB_clk_rc,
           dac_clk        => dac_clk_rc,
           dac_dat        => dac_dat_rc,
           bias_dac_ncs   => bias_dac_ncs_rc,
           offset_dac_ncs => offset_dac_ncs_rc,
           lvds_cmd       => lvds_cmd,
           lvds_sync      => lvds_sync,
           lvds_spare     => lvds_spare,
           lvds_txa       => lvds_txa_rc,
           lvds_txb       => lvds_txb_rc,
           red_led        => red_led_rc,
           ylw_led        => ylw_led_rc,
           grn_led        => grn_led_rc,
           dip_sw3        => dip_sw3_rc,
           dip_sw4        => dip_sw4_rc,
           wdog           => wdog_rc,
           slot_id        => slot_id_rc,
           card_id        => card_id_rc,
           mictor         => mictor_rc);
   
     lvds_reply_rc1_a <= lvds_txa_rc;
     lvds_reply_rc1_b <= lvds_txb_rc;
   
   
   -- set up hotlink receiver signals 
   fibre_rx_rvs    <= '0';  -- no violation
   fibre_rx_status <= '1';  -- status ok
   fibre_rx_sc_nd  <= '0';  -- data     
          
   ------------------------------------------------
   -- Create test bench clock
   -------------------------------------------------
   inclk        <= not inclk        after clk_period/2;
   fibre_rx_ckr <= not fibre_rx_ckr after fibre_clk_period/2;
   
   ------------------------------------------------
   -- Create test bench stimuli
   -------------------------------------------------
   
   stimuli : process

   procedure do_reset is
   begin
      rst_n <= '0';
      wait for clk_period*50 ;
      rst_n <= '1';
       
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

       command <= command_wb;
       address_id <= gainp0_cmd;
       data_valid <= X"00000029";        -- number of data to write
       data       <= X"00000007";
       load_preamble;
       load_command;
       load_checksum;
      report "End of writing gainp0 command";
      
      wait for 160 us;


       command <= command_rb;
        address_id <= gainp0_cmd;
        data_valid <= X"00000029";
        data       <= X"00000000";
        load_preamble;
        load_command;
        load_checksum;
      report "End of reading gainp0 command";

      wait for 160 us;

      
       command <= command_wb;
       address_id <= sa_bias_cmd;
       data_valid <= X"00000008";        -- number of data to write
       data       <= X"00000011";
       load_preamble;
       load_command;
       load_checksum;
      report "End of writing sa_bias command";
      
      wait for 160 us;
      
       command <= command_wb;
       address_id <= servo_mode_cmd;
       data_valid <= X"00000001";        -- number of data to write
       data       <= X"00000032";
       load_preamble;
       load_command;
       load_checksum;
      report "End of writing servo_mode command";
      
       wait for 160 us;


      assert false report "Simulation done." severity FAILURE;
   end process stimuli;
   
end tb1;
