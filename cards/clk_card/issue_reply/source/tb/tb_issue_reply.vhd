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
-- <revision control keyword substitutions e.g. $Id: tb_issue_reply.vhd,v 1.18 2004/11/02 07:38:09 bburger Exp $>
--
-- Project: Scuba 2
-- Author: David Atkinson
-- Organisation: UK ATC
--
-- Title
-- tb_issue_reply
--
-- Description:
-- Test bed for the issue_reply chain
--
-- Revision history:
-- <date $Date: 2004/11/02 07:38:09 $> - <text> - <initials $Author: bburger $>
-- <log $log$>
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.issue_reply_pack.all;
use work.async_pack.all;
use work.sync_gen_pack.all;
use work.dispatch_pack.all;
use work.wbs_ac_dac_ctrl_pack.all;
use work.ac_dac_ctrl_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.frame_timing_pack.all;
use sys_param.data_types_pack.all;

entity tb_issue_reply is     
end tb_issue_reply;

architecture tb of tb_issue_reply is 
 
   signal   t_rst_i            : std_logic;
     
   -- Inputs from the fibre
   signal t_rx_data_i         : std_logic_vector(7 DOWNTO 0);
   signal t_nRx_rdy_i         : std_logic;
   signal t_rvs_i             : std_logic;
   signal t_rso_i             : std_logic;
   signal t_rsc_nRd_i         : std_logic;    
   
   -- RX signals
   signal t_rx_dat             : std_logic_vector(31 downto 0);
   signal t_rx_rdy             : std_logic;
   signal t_rx_ack             : std_logic;
   signal t_rx                 : std_logic;

   -- Clock signals
   signal t_cksum_err_o        : std_logic;     
   signal t_tx                 : std_logic; -- transmitter output pin
   signal t_clk_i              : std_logic := '0';    
   signal t_fibre_clkr         : std_logic := '1'; 
   signal t_clk_200mhz_i       : std_logic := '0';
   signal comm_clk             : std_logic := '0';
   constant pci_dsp_dly        : TIME := 160 ns ;   -- delay between tranmission of 4byte packets from PCI 
   constant clk_prd            : TIME := 20 ns;    -- 50Mhz clock
   constant clk_prd_200mhz     : TIME := 5 ns;    -- 200Mhz clock
   constant fibre_clkr_prd     : TIME := 40 ns;   -- 25MHz clock   
   constant comm_clk_period    : TIME := 40 ns;
   constant mem_clk_period     : TIME := 5 ns;
   constant clk_period         : TIME := 20 ns;

   constant preamble1          : std_logic_vector(7 downto 0) := X"A5";
   constant preamble2          : std_logic_vector(7 downto 0) := X"5A";
   constant pre_fail           : std_logic_vector(7 downto 0) := X"55";
   constant command_wb         : std_logic_vector(31 downto 0) := X"20205742";
   constant command_rb         : std_logic_vector(31 downto 0) := x"20205242";
   constant command_go         : std_logic_vector(31 downto 0) := X"2020474F";
   constant command_st         : std_logic_vector(31 downto 0) := x"20205354";
   signal address_id           : std_logic_vector(31 downto 0) := X"00000000";--X"0002015C";
   
   constant ret_dat_s_num_data : std_logic_vector(31 downto 0) := X"00000002";  -- 2 data words, start and stop frame #
   signal ret_dat_s_start      : std_logic_vector(31 downto 0) := X"00000003";
   signal ret_dat_s_stop       : std_logic_vector(31 downto 0) := X"00000011";   
   constant ret_dat_num_data   : std_logic_vector(31 downto 0) := X"00000001";  -- 2 data words, start and stop frame #   
   
   constant ret_dat_cmd        : std_logic_vector(31 downto 0) := X"000B0030";  -- card id=4, ret_dat command
   constant ret_dat_s_cmd      : std_logic_vector(31 downto 0) := X"00020034";  -- card id=0, ret_dat_s command
--   constant ret_dat_cmd        : std_logic_vector(31 downto 0) := x"00" & ALL_READOUT_CARDS  & x"00" & RET_DAT_ADDR;
--   constant ret_dat_s_cmd      : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD         & x"00" & RET_DAT_S_ADDR;
   constant flux_fdbck_cmd     : std_logic_vector(31 downto 0) := x"00" & BIAS_CARD_1        & x"00" & FLUX_FB_ADDR;
   constant sram1_strt_cmd     : std_logic_vector(31 downto 0) := x"00" & CLOCK_CARD         & x"00" & SRAM1_STRT_ADDR;
   constant on_bias_cmd        : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ON_BIAS_ADDR;
   constant off_bias_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & OFF_BIAS_ADDR;
   constant row_order_cmd      : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ROW_ORDER_ADDR;
   constant enbl_mux_cmd       : std_logic_vector(31 downto 0) := x"00" & ADDRESS_CARD       & x"00" & ENBL_MUX_ADDR;
  
   constant no_std_data        : std_logic_vector(31 downto 0) := X"00000001";
   constant data_block         : positive := 58;
   constant data_word1         : std_logic_vector(31 downto 0) := X"00001234";
   constant data_word2         : std_logic_vector(31 downto 0) := X"00005678";
   constant check_err          : std_logic_vector(31 downto 0) := X"fafafafa"; 
   
   signal checksum             : std_logic_vector(31 downto 0) := X"00000000";
   signal command              : std_logic_vector(31 downto 0);   
   signal data_valid           : std_logic_vector(31 downto 0); -- used to be set to constant X"00000028"
   signal data                 : std_logic_vector(31 downto 0) := X"00000001";--integer := 1;
  
   signal count                : integer;
   
   signal dv_i                 : std_logic := '0';
   signal dv_en_i              : std_logic := '0';
   
   signal sync_pulse           : std_logic;
   signal sync_number          : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   
   -- wbs_ac_dac_ctrl signals
   signal on_off_addr             : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0) := (others => '0');
   signal W_DAT_O                 : std_logic_vector(WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_O                : std_logic_vector(WB_ADDR_WIDTH - 1 downto 0 );
   signal W_TGA_O                 : std_logic_vector(WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_O                  : std_logic;
   signal W_STB_O                 : std_logic;
   signal W_CYC_O                 : std_logic;
   signal W_DAT_I                 : std_logic_vector(WB_DATA_WIDTH - 1 downto 0 ) := (others => '0');
   signal W_ACK_I                 : std_logic;
   signal W_WDT_RST_O             : std_logic;
   
   signal frame_rst               : std_logic := '0';
   signal init_window_req         : std_logic := '0';
   signal sample_num              : integer := 40;
   signal sample_delay            : integer := 10;
   signal feedback_delay          : integer := 6;
   signal address_on_delay        : integer := 3;
   signal update_bias             : std_logic;
   signal dac_dat_en              : std_logic;
   signal adc_coadd_en            : std_logic;
   signal restart_frame_1row_prev : std_logic;
   signal restart_frame_aligned   : std_logic; 
   signal restart_frame_1row_post : std_logic;
   signal row_switch              : std_logic;
   signal row_en                  : std_logic;
   signal initialize_window       : std_logic;
   
   signal dac_id                  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal on_data                 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal off_data                : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal mux_en                  : std_logic;
   signal dac_data                : w14_array11;   
   signal dac_clks                : std_logic_vector(NUM_OF_ROWS downto 0);
   
   component issue_reply
   port(
      -- global signals
      rst_i          : in std_logic;
      clk_i          : in std_logic;

      -- inputs from the fibre
      fibre_clkr_i   : in std_logic;
      rx_data_i      : in std_logic_vector(7 DOWNTO 0);
      nRx_rdy_i      : in std_logic;
      rvs_i          : in std_logic;
      rso_i          : in std_logic;
      rsc_nRd_i      : in std_logic;        
      
      -- lvds_tx interface
      tx_o           : out std_logic;  -- transmitter output pin
      clk_200mhz_i   : in std_logic;  -- PLL locked 25MHz input clock for the
      sync_pulse_i   : in std_logic;
      sync_number_i  : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
   ); 
   end component;
    
begin

   dut : issue_reply
   port map
   (
      rst_i                      => t_rst_i,
      clk_i                      => t_clk_i,      
      fibre_clkr_i               => t_fibre_clkr,
      rx_data_i                  => t_rx_data_i,
      nRx_rdy_i                  => t_nrx_rdy_i,
      rvs_i                      => t_rvs_i,
      rso_i                      => t_rso_i,
      rsc_nRd_i                  => t_rsc_nrd_i,   
      tx_o                       => t_tx,  -- transmitter output pin
      clk_200mhz_i               => t_clk_200mhz_i,  -- PLL locked 25MHz input clock for the
      sync_pulse_i               => sync_pulse,
      sync_number_i              => sync_number
   ); 
   
   i_sync_gen : sync_gen
   port map
   (
      clk_i                      => t_clk_i,
      rst_i                      => t_rst_i,
      dv_i                       => dv_i,
      dv_en_i                    => dv_en_i,
      sync_o                     => sync_pulse,
      sync_num_o                 => sync_number      
   );
   
   i_dispatch : DISPATCH
   generic map
   (
      CARD   => ADDRESS_CARD 
   )
   port map
   (
      CLK_I                      => t_clk_i,
      MEM_CLK_I                  => t_clk_200mhz_i,
      COMM_CLK_I                 => t_clk_200mhz_i,
      RST_I                      => t_rst_i,
      LVDS_CMD_I                 => t_tx,
      LVDS_REPLY_O               => t_rx,
      DAT_O                      => W_DAT_O,
      ADDR_O                     => W_ADDR_O,
      TGA_O                      => W_TGA_O,
      WE_O                       => W_WE_O,
      STB_O                      => W_STB_O,
      CYC_O                      => W_CYC_O,
      DAT_I                      => W_DAT_I,
      ACK_I                      => W_ACK_I,
      WDT_RST_O                  => W_WDT_RST_O
   );

   rx : lvds_rx
   port map
   (
      clk_i                      => t_clk_i,
      comm_clk_i                 => t_clk_200mhz_i,
      rst_i                      => t_rst_i,
      dat_o                      => t_rx_dat,
      rdy_o                      => t_rx_rdy,
      ack_i                      => t_rx_ack,
      lvds_i                     => t_tx
   );
   
   i_wbs_ac_dac_ctrl : wbs_ac_dac_ctrl
   port map
   (
      on_off_addr_i              => on_off_addr,
      dac_id_o                   => dac_id,
      on_data_o                  => on_data,
      off_data_o                 => off_data, 
      mux_en_o                   => mux_en,
      clk_i                      => t_clk_i,
      mem_clk_i                  => t_clk_200mhz_i,
      rst_i                      => t_rst_i,      
      dat_i                      => W_DAT_O,
      addr_i                     => W_ADDR_O,
      tga_i                      => W_TGA_O,
      we_i                       => W_WE_O,
      stb_i                      => W_STB_O,
      cyc_i                      => W_CYC_O,
      dat_o                      => W_DAT_I,
      ack_o                      => W_ACK_I
   );
   
   i_frame_timing : frame_timing
   port map
   (
      clk_i                      => t_clk_i,
      rst_i                      => t_rst_i,
      sync_i                     => sync_pulse,
      frame_rst_i                => frame_rst,                                              
      init_window_req_i          => init_window_req,                                        
      sample_num_i               => sample_num,             
      sample_delay_i             => sample_delay,           
      feedback_delay_i           => feedback_delay,         
      address_on_delay_i         => address_on_delay,                                       
      update_bias_o              => update_bias,            
      dac_dat_en_o               => dac_dat_en,             
      adc_coadd_en_o             => adc_coadd_en,           
      restart_frame_1row_prev_o  => restart_frame_1row_prev,
      restart_frame_aligned_o    => restart_frame_aligned,  
      restart_frame_1row_post_o  => restart_frame_1row_post,
      row_switch_o               => row_switch,             
      row_en_o                   => row_en,                 
      initialize_window_o        => initialize_window      
   );                            
                                 
   i_ac_dac_ctrl : ac_dac_ctrl   
   port map
   (
      dac_data_o                 => dac_data,
      dac_clks_o                 => dac_clks,                                 
      on_off_addr_o              => on_off_addr,
      dac_id_i                   => dac_id,
      on_data_i                  => on_data,
      off_data_i                 => off_data,
      mux_en_i                   => mux_en,     
      row_switch_i               => row_switch,
      restart_frame_aligned_i    => restart_frame_aligned,
      row_en_i                   => row_en,                                
      clk_i                      => t_clk_i,
      mem_clk_i                  => t_clk_200mhz_i,
      rst_i                      => t_rst_i
   );                         
   
   -- set up hotlink receiver signals 
   t_rx_ack <= t_rx_rdy;
   t_rvs_i         <= '0';  -- no violation
   t_rso_i         <= '1';  -- status ok
   t_rsc_nRd_i     <= '0';  -- data     
          
   ------------------------------------------------
   -- Create test bench clock
   -------------------------------------------------
  
   t_clk_i         <= not t_clk_i        after clk_prd/2;
   t_clk_200mhz_i  <= not t_clk_200mhz_i after clk_prd_200mhz/2;   
   t_fibre_clkr    <= not t_fibre_clkr   after fibre_clkr_prd/2;
   comm_clk        <= not comm_clk       after comm_clk_period/2;
    
   ------------------------------------------------
   -- Create test bench stimuli
   -------------------------------------------------
   
   stimuli : process
  
   ------------------------------------------------
   -- Stimulus procedures
   -------------------------------------------------
      
   procedure do_reset is
   begin
      t_rst_i <= '1';
      wait for clk_prd*5 ;
      t_rst_i <= '0';
      wait for clk_prd*5 ;   
      assert false report " Resetting the DUT." severity NOTE;
   end do_reset;
   --------------------------------------------------
  
   procedure load_preamble is
   begin
   
   for I in 0 to 3 loop
      t_nrx_rdy_i    <= '1';  -- data not ready (active low)
      t_rx_data_i  <= preamble1;
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;   
   
   for I in 0 to 3 loop
      t_nrx_rdy_i    <= '1';  -- data not ready (active low)
      t_rx_data_i  <= preamble2;
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i    <= '0';
      wait for fibre_clkr_prd * 0.6;
   end loop;     
   
   t_nrx_rdy_i <= '1';
   wait for pci_dsp_dly;     
    
   assert false report "preamble OK" severity NOTE;
   end load_preamble;
   
   ---------------------------------------------------------    
 
   procedure load_command is 
   begin   
      checksum  <= command;
    
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
    
      assert false report "command code loaded" severity NOTE;
      t_nrx_rdy_i <= '1';
      wait for pci_dsp_dly;   
     
      -- load up address_id
      checksum <= checksum XOR address_id;
     
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
     
      assert false report "address id loaded" severity NOTE;
      t_nrx_rdy_i <= '1';
      wait for pci_dsp_dly; 
     
      -- load up data valid       
      checksum <= checksum XOR data_valid;
  
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      assert false report "data valid loaded" severity NOTE;
      t_nrx_rdy_i <= '1';
      wait for pci_dsp_dly; 
      
      -- load up data block
      -- first load valid data
      for I in 0 to (To_integer((Unsigned(data_valid)))-1) loop
      --for I in 0 to (data_valid-1) loop
         
         t_nrx_rdy_i   <= '1';
         
         t_rx_data_i <= data(7 downto 0);
         checksum (7 downto 0) <= checksum (7 downto 0) XOR data(7 downto 0);
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         t_nrx_rdy_i   <= '1';
         
         t_rx_data_i <= data(15 downto 8);
         checksum (15 downto 8) <= checksum (15 downto 8) XOR data(15 downto 8);
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         t_nrx_rdy_i   <= '1';

         t_rx_data_i <= data(23 downto 16);
         checksum (23 downto 16) <= checksum (23 downto 16) XOR data(23 downto 16);
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         t_nrx_rdy_i   <= '1';
         
         t_rx_data_i <= data(31 downto 24);
         checksum (31 downto 24) <= checksum (31 downto 24) XOR data(31 downto 24);
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         
         case address_id is
            when ret_dat_s_cmd => data <= ret_dat_s_stop;
            when ret_dat_cmd   => data <= (others => '0');
            when others        => data <= data + 1;
         end case;
         
         wait for fibre_clkr_prd * 0.6;
         
         t_nrx_rdy_i <= '1';
         wait for pci_dsp_dly;        
      end loop;
    
      for J in (To_integer((Unsigned(data_valid)))) to data_block-1 loop
         t_nrx_rdy_i   <= '1';
         t_rx_data_i <= X"00";
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         t_nrx_rdy_i   <= '1';
         t_rx_data_i <= X"00";
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         t_nrx_rdy_i   <= '1';
         t_rx_data_i <= X"00";
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         wait for fibre_clkr_prd * 0.6;
         
         t_nrx_rdy_i   <= '1';
         t_rx_data_i <= X"00";
         wait for fibre_clkr_prd * 0.4;
         t_nrx_rdy_i   <= '0';
         wait for fibre_clkr_prd * 0.6;
            
         t_nrx_rdy_i <= '1';
         wait for pci_dsp_dly; 
      end loop;
        
      assert false report "data words loaded to memory...." severity NOTE;

   end load_command;
    
   ------------------------------------------------------

   procedure load_checksum is
    
      begin 
         
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(7 downto 0);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(15 downto 8);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(23 downto 16);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(31 downto 24);
      wait for fibre_clkr_prd * 0.4;
      t_nrx_rdy_i   <= '0';
      wait for fibre_clkr_prd * 0.6;
         
      assert false report "checksum loaded...." severity NOTE;  
       
      t_nrx_rdy_i <= '1';
      wait for pci_dsp_dly; 
   
   end load_checksum;
       
  
 --------------------------------------------------------
 ---- BEGIN TEST
 ------------------------------------------------------      
       
   begin
      
      do_reset;    
      
      -- This is a 'WB cc sram1_start A B C' command
      -- This command should not be parsed by the Address Card Wishbone Slave
      command <= command_wb;
      address_id <= sram1_strt_cmd;
      data_valid <= X"00000001";--X"00000028";
      data       <= X"0000000A";
      load_preamble;
      load_command;
      load_checksum;
      
      wait for 80 us;

      -- This is a 'WB ac on_bias 0 1 2 .. 40' command
      -- This command should excercise the Address Card's wbs_ac_dac_ctrl block
      command <= command_wb;
      address_id <= on_bias_cmd;
      data_valid <= X"00000029"; --41 values
      data       <= X"00000000";
      load_preamble;
      load_command;
      load_checksum;
      
      wait for 80 us;

      -- This is a 'WB ac on_bias 0 1 2 .. 40' command
      -- This command should excercise the Address Card's wbs_ac_dac_ctrl block
      command <= command_wb;
      address_id <= off_bias_cmd;
      data_valid <= X"00000029"; --41 values
      data       <= X"00000029";
      load_preamble;
      load_command;
      load_checksum;
      
      wait for 80 us;

      -- This is a 'WB ac on_bias 0 1 2 .. 40' command
      -- This command should excercise the Address Card's wbs_ac_dac_ctrl block
      command <= command_wb;
      address_id <= row_order_cmd;
      data_valid <= X"00000029"; --41 values
      data       <= X"00000000";
      load_preamble;
      load_command;
      load_checksum;
      
      wait for 80 us;

      command <= command_wb;
      address_id <= enbl_mux_cmd;
      data_valid <= X"00000001"; --41 values
      data       <= X"00000001";
      load_preamble;
      load_command;
      load_checksum;
      
      wait for 240 us;
        
--      -- This sequence of two commands will be used to test the ability to stop the return of data frames in mid-sequence
--      ret_dat_s_start <= x"00000003";
--      ret_dat_s_stop  <= x"00000008";
--      
--      command <= command_wb;
--      address_id <= ret_dat_s_cmd;
--      data_valid <= ret_dat_s_num_data;
--      data <= ret_dat_s_start; -- start is 0x2, end is 0x8
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--
--      command <= command_go;
--      address_id <= ret_dat_cmd;
--      data_valid <= ret_dat_num_data;
--      data <= (others=>'1');
--      load_preamble;
--      load_command;
--      load_checksum;    
--      
--      wait for 1 us;  
--
--      -- This stop command seems to cause problems if it occurs after the ret_dat commands have already been issued to the cmd_queue
--      -- It currently doesn't work because the cmd_queue fills up faster than the the stop command can be processed.
----      command <= command_st;
----      address_id <= ret_dat_cmd;
----      data_valid <= ret_dat_num_data;
----      data <= (others=>'0');
----      load_preamble;
----      load_command;
----      load_checksum;    
--      
--      wait for 10*55 us;  
-----------------------------------------------------------------

--        -- This is a 'WB bc1 flux_fdbck 8' command x"00070020"
--      command <= command_wb;
--      
--      address_id <= flux_fdbck_cmd;
--      data_valid <= X"00000001";--X"00000028";
--      data       <= X"00000008";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--      
--      -- This is a 'RB cc sram1_start' command x"005C0020"
--      command <= command_rb;
--      
--      address_id <= sram1_strt_cmd;
--      data_valid <= X"00000001";--X"00000028";
--      data       <= X"00000000";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--      
--      -- do a return data setup command 'WB sys ret_dat_s 2 8'
--      -- ** note, you will not see any output for this command as it does setup in the cmd_translator only
--      address_id <= ret_dat_s_cmd;
--      data_valid <= ret_dat_s_num_data;
--      data <= ret_dat_s_start; -- start is 0x2, end is 0x8
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 100 us;
--
--      command <= command_go;
--      address_id <= ret_dat_cmd;
--      data_valid <= no_std_data;
--      data <= (others=>'0');
--      load_preamble;
--      load_command;
--      load_checksum;    
--      
--      wait for 8*55 us;  
      

--      --wait until cmd_rdy = '1';
--      --wait for clk_prd;
--      wait until t_macro_instr_rdy_o = '1';
--      wait for clk_prd;
--      t_ack_i <= '1'; 
--      assert false report "Command Acknowledged....." severity NOTE;
--      wait until t_macro_instr_rdy_o = '0';
--      t_ack_i <= '0';
--      
--      -- load a wb command with checksum error
--      
----      command <= command_wb;
----      load_preamble;
----      load_command;
----      checksum <= check_err;
----      wait for 100 ns;
----      load_checksum;
----      wait until t_cksum_err_o = '1';
----      wait until t_cksum_err_o = '0';
----      assert false report "command 2 finished with check err detected" severity NOTE;
----      
--      --wait until cmd_data = X"28282828";      
--      --wait for clk_prd*10;
--      
--      -- do a return data setup command
--      address_id <= ret_dat_s_cmd;
--      data_valid <= ret_dat_s_num_data;
--      data <= ret_dat_s_start;
--      t_ack_i <= '0';
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      --wait until cmd_rdy = '1';
--      --wait for clk_prd;
--      --wait until t_macro_instr_rdy_o = '1';
--      wait for 10*clk_prd;
--      --t_ack_i <= '1'; 
--      assert false report "Performed the RET_DAT_S command....." severity NOTE;
--      --wait until t_macro_instr_rdy_o = '0';
--      --t_ack_i <= '0';      
--      wait for 1500 ns;
-- 
-- 
--      -- do a return data using the start and stop frames from the setup command
--      command <= command_go;
--      address_id <= ret_dat_cmd;
--      data_valid <= no_std_data;
--      data <= (others=>'0');
--      t_ack_i <= '0';
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      --wait until cmd_rdy = '1';
--      --wait for clk_prd;
--      count <= 0;
--      for J in (To_integer((Unsigned(ret_dat_s_start)))) to (To_integer((Unsigned(ret_dat_s_stop)))) loop
--     
--         wait until t_macro_instr_rdy_o = '1';
--         wait for 10*clk_prd;
--         t_ack_i <= '1'; 
--         assert false report "Performed the RET_DAT command....." severity NOTE;
--         count <= count + 1;
--         wait until t_macro_instr_rdy_o = '0';
--         t_ack_i <= '0';      
--
--      end loop;
--      assert false report "Done the RET_DAT command....." severity NOTE;
--      wait for 100*clk_prd;
--
--
--      -- perform another ret_dat command, but this one gets interrupted by a simple command
--      count <= 0;
--      
--      command <= command_go;
--      address_id <= ret_dat_cmd;
--      data_valid <= no_std_data;
--      data <= (others=>'0');
--      t_ack_i <= '0';
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      
--      for J in (To_integer((Unsigned(ret_dat_s_start)))) to (To_integer((Unsigned(ret_dat_s_stop-51)))) loop
--     
--         wait until t_macro_instr_rdy_o = '1';
--         wait for 10*clk_prd;
--         t_ack_i <= '1'; 
--         assert false report "Performed the second RET_DAT command....." severity NOTE;
--         count <= count + 1;
--         wait until t_macro_instr_rdy_o = '0';
--         t_ack_i <= '0';      
--
--      end loop;
--      
--      wait until t_macro_instr_rdy_o = '1';
--      wait for 10*clk_prd;
--      
--      -- the 'simple command' inturrupting the ret_dat
--      assert false report "The simple command is loading and interrupting the second RET_DAT command....." severity NOTE;
--      command <= command_wb;
--      address_id <= simple_cmd;
--      data_valid <= X"00000028";
--      load_preamble;
--      load_command;
--      load_checksum;
--      
--      wait for 3000 ns;  
--      -- finish off the current ret_dat command (ret_dat_s_stop-50)
--      t_ack_i <= '1'; 
--      assert false report "Finishing off current RET_DAT command....." severity NOTE;
--      count <= count + 1;
--      wait until t_macro_instr_rdy_o = '0';
--      t_ack_i <= '0';    
--      
--      -- back to the simple command
--      --wait for 1500 ns;
--      wait until t_macro_instr_rdy_o = '1';
--      wait for clk_prd;
--      t_ack_i <= '1'; 
--      assert false report "Simple Command Acknowledged....." severity NOTE;
--      wait until t_macro_instr_rdy_o = '0';
--      t_ack_i <= '0';
--      
--      -- this is to allow the data to be clocked out
--      -- to the cmd_translator
--      --wait for 1500 ns;      
--      
--      --resume with the remainder of the ret_dat commands
--      for J in (To_integer((Unsigned(ret_dat_s_stop-49)))) to (To_integer((Unsigned(ret_dat_s_stop)))) loop
--     
--         wait until t_macro_instr_rdy_o = '1';
--         wait for 10*clk_prd;
--         t_ack_i <= '1'; 
--         assert false report "Performed the second RET_DAT command....." severity NOTE;
--         count <= count + 1;
--         wait until t_macro_instr_rdy_o = '0';
--         t_ack_i <= '0';      
--
--      end loop;      
      
      --wait for 100*clk_prd;
      --wait for 3000 ns;  
      --wait for 120 us;
      
      assert false report "Simulation done." severity FAILURE;

   end process stimuli;
   
end tb;