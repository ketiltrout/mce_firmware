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
-- wbs_fb_data.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- This block instantiates the administator for P, I, D, Z, adc_offset_dat, and
-- the Miscellanous memory blocks.  Note that each admin block, excpet for the
-- Miscellanous admin, has multiple channel support.
-- The output of each admin block to the Dispatch is multiplexed according to
-- the addr_i value.  Also, the acknowledge from each admin block is logically
-- ORed for the Dispatch block.
--
--
-- Ports:
-- #clk_50_i: Global clock.
-- #rst_i: Global rest.   
-- #adc_offset_dat_ch0_o: adc_offset Data for flux_loop_ctrl channel0.
-- #adc_offset_addr_ch0_i: Read address from flux_loop_ctrl channle0.
-- #p_dat_ch0_o: P Data for flux_loop_ctrl channel0.
-- #p_addr_ch0_i: Read address from flux_loop_ctrl channle0.
-- #i_dat_ch0_o: I Data for flux_loop_ctrl channel0.
-- #i_addr_ch0_i: Read address from flux_loop_ctrl channle0.
-- #d_dat_ch0_o: D Data for flux_loop_ctrl channel0.
-- #d_addr_ch0_i: Read address from flux_loop_ctrl channle0.
-- #z_dat_ch0_o: Z Data for flux_loop_ctrl channel0.
-- #z_addr_ch0_i: Read address from flux_loop_ctrl channle0. 
-- #sa_bias_ch0_o: sa_bias Data for flux_loop_ctrl channel0.
-- #offset_dat_ch0_o: offset_dat Data for flux_loop_ctrl channel0.
-- #const_val_ch0_o: const_val  Data for flux_loop_ctrl Channel0.
-- ####### Similarly for channels 1 to 7
-- #filter_coeff0_o: First filter coefficient to all flux_loop_ctrl.
-- #filter_coeff1_o: Second filter coefficient to all flux_loop_ctrl.
-- #filter_coeff2_o: Third filter coefficient to all flux_loop_ctrl.
-- #filter_coeff3_o: Fourth filter coefficient to all flux_loop_ctrl.
-- #filter_coeff4_o: Fifth filter coefficient to all flux_loop_ctrl.
-- #filter_coeff5_o: Sixth filter coefficient to all flux_loop_ctrl .
-- #filter_coeff6_o: Seventh filter coefficient to all flux_loop_ctrl.
-- #servo_mode_o: servo_mode Data for flux_loop_ctrl.
-- #ramp_step_size_o: ramp_step_size Data for flux_loop_ctrl.
-- #ramp_amp_o: ramp_ampl Data for flux_loop_ctrl.
-- #num_ramp_frame_cycles_o: num_ramp_frame_cycles Data for flux_loop_ctrl.
-- #dat_i: Data in from Dispatch
-- #addr_i: Address from Dispatch showing the address of memory banks. This is
-- kept constant during a read or write cycle.
-- #tga_i: Address Tag from Dispatch.  This is incremented during a read or
-- write cycle.  Therefore, it is used as an index to the location in the
-- memory bank
-- #we_i: Write Enable input from Dispatch
-- #stb_i: Strobe signal from Dispatch.  Indicates if an address is valid or
-- not. See Wishbone manual page 54 and 57.  
-- #cyc_i: Input from Dispatch indicating a read or write cycle is in progress
-- #dat_o: Data out to Dispatch.
-- #ack_o: Acknowledge signal to Dispatch on completion of any read or write
-- cycle. 
--
--
--
-- Revision history:
-- 
-- $Log: wbs_fb_data.vhd,v $
-- Revision 1.6  2006/11/24 20:47:38  mandana
-- splitted fb_const to be channel specific
--
-- Revision 1.5  2006/02/07 22:12:16  bburger
-- Bryce:  registered data_o and ack_o to break up a large combinatorial loop
--
-- Revision 1.4  2005/09/14 23:48:41  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.3  2004/12/07 19:39:29  mohsen
-- Changed default datapath to zero rather than a ch0
--
-- Revision 1.2  2004/11/26 18:28:35  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/11/20 01:22:02  mohsen
-- Initial release
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


library work;
use work.wbs_fb_data_pack.all;

-- Call Parent Library
use work.flux_loop_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;



entity wbs_fb_data is
  
  port (

    -- Global signals
    clk_50_i                : in std_logic;
    rst_i                   : in std_logic;


    -- PER Flux_Loop_Ctrl Channel Interface
    adc_offset_dat_ch0_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch0_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch0_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch0_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch0_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch0_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch0_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          


    adc_offset_dat_ch1_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch1_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch1_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch1_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch1_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch1_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch1_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          
    

    adc_offset_dat_ch2_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch2_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch2_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch2_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch2_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch2_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch2_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          

    
    adc_offset_dat_ch3_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch3_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch3_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch3_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch3_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch3_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch3_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          
    
  
    adc_offset_dat_ch4_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch4_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch4_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch4_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch4_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch4_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch4_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          
   

    adc_offset_dat_ch5_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch5_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch5_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch5_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch5_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch5_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch5_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          

    
    adc_offset_dat_ch6_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch6_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch6_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch6_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch6_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch6_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch6_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          
    

    adc_offset_dat_ch7_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch7_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    p_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    p_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);   
    i_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    i_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    d_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    d_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0); 
    flux_quanta_dat_ch7_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    flux_quanta_addr_ch7_i  : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0); 
    sa_bias_ch7_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch7_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch7_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          


    -- All Flux_Loop_Ctrl Channels
    filter_coeff0_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff1_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff2_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff3_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff4_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff5_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff6_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    servo_mode_o            : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    ramp_step_size_o        : out std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          
    ramp_amp_o              : out std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           
    num_ramp_frame_cycles_o : out std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
    flux_jumping_en_o       : out std_logic;


    -- signals to/from dispatch  (wishbone interface)
    dat_i                   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
    addr_i                  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
    tga_i                   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- 
    we_i                    : in std_logic;                                        -- write//read enable
    stb_i                   : in std_logic;                                        -- strobe 
    cyc_i                   : in std_logic;                                        -- cycle
    dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);      -- data out
    ack_o                   : out std_logic);                                      -- acknowledge out
    


end wbs_fb_data;


architecture struct of wbs_fb_data is

  -----------------------------------------------------------------------------
  -- Signals from P/I/D/Z/ADC Banks Admin and Miscellanous Bank
  -----------------------------------------------------------------------------
  signal qa_p_bank     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_i_bank     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_d_bank     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_flux_quanta_bank     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_misc_bank  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal ack_p_bank    : std_logic;
  signal ack_i_bank    : std_logic;
  signal ack_d_bank    : std_logic;
  signal ack_flux_quanta_bank    : std_logic;
  signal ack_adc_offset_bank  : std_logic;
  signal ack_misc_bank : std_logic;



  
--   -----------------------------------------------------------------------------
--   -- Signals from Miscellanous Controller
--   -----------------------------------------------------------------------------
--   signal wren_misc_bank           : std_logic;
--   signal filter_coeff_wraddress   : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
--   signal servo_mode_wraddress     : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
--   signal ramp_step_size_wraddress : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
--   signal const_val_wraddress      : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
--   signal num_ramp_frm_wraddress   : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
--   signal mode_flag_ctrl_wraddress : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
--   signal sa_bias_wraddress        : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
--   signal offset_dat_wraddress     : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  


  
begin  -- struct

  
  -----------------------------------------------------------------------------
  -- Instantiation of P Banks Admin
  -----------------------------------------------------------------------------
  i_p_banks_admin : pid_ram_admin
    generic map(
       DATA_TYPE => P_COEFFICIENT)
    port map (
       clk_50_i     => clk_50_i,
       rst_i        => rst_i,
       dat_ch0_o    => p_dat_ch0_o,
       addr_ch0_i   => p_addr_ch0_i,
       dat_ch1_o    => p_dat_ch1_o,
       addr_ch1_i   => p_addr_ch1_i,
       dat_ch2_o    => p_dat_ch2_o,
       addr_ch2_i   => p_addr_ch2_i,
       dat_ch3_o    => p_dat_ch3_o,
       addr_ch3_i   => p_addr_ch3_i,
       dat_ch4_o    => p_dat_ch4_o,
       addr_ch4_i   => p_addr_ch4_i,
       dat_ch5_o    => p_dat_ch5_o,
       addr_ch5_i   => p_addr_ch5_i,
       dat_ch6_o    => p_dat_ch6_o,
       addr_ch6_i   => p_addr_ch6_i,
       dat_ch7_o    => p_dat_ch7_o,
       addr_ch7_i   => p_addr_ch7_i,
       dat_i        => dat_i,
       addr_i       => addr_i,
       tga_i        => tga_i,
       we_i         => we_i,
       stb_i        => stb_i,
       cyc_i        => cyc_i,
       qa_bank_o  => qa_p_bank,
       ack_bank_o => ack_p_bank);


  
  -----------------------------------------------------------------------------
  -- Instantiation of I Banks Admin
  -----------------------------------------------------------------------------

  i_i_banks_admin: pid_ram_admin
    generic map(
       DATA_TYPE => I_COEFFICIENT)
    port map (
       clk_50_i     => clk_50_i,
       rst_i        => rst_i,
       dat_ch0_o    => i_dat_ch0_o,
       addr_ch0_i   => i_addr_ch0_i,
       dat_ch1_o    => i_dat_ch1_o,
       addr_ch1_i   => i_addr_ch1_i,
       dat_ch2_o    => i_dat_ch2_o,
       addr_ch2_i   => i_addr_ch2_i,
       dat_ch3_o    => i_dat_ch3_o,
       addr_ch3_i   => i_addr_ch3_i,
       dat_ch4_o    => i_dat_ch4_o,
       addr_ch4_i   => i_addr_ch4_i,
       dat_ch5_o    => i_dat_ch5_o,
       addr_ch5_i   => i_addr_ch5_i,
       dat_ch6_o    => i_dat_ch6_o,
       addr_ch6_i   => i_addr_ch6_i,
       dat_ch7_o    => i_dat_ch7_o,
       addr_ch7_i   => i_addr_ch7_i,
       dat_i        => dat_i,
       addr_i       => addr_i,
       tga_i        => tga_i,
       we_i         => we_i,
       stb_i        => stb_i,
       cyc_i        => cyc_i,
       qa_bank_o  => qa_i_bank,
       ack_bank_o => ack_i_bank);
  
  -----------------------------------------------------------------------------
  -- Instantiation of D Banks Admin
  -----------------------------------------------------------------------------

  i_d_banks_admin: pid_ram_admin
    generic map(
       DATA_TYPE => D_COEFFICIENT)
    port map (
       clk_50_i     => clk_50_i,
       rst_i        => rst_i,
       dat_ch0_o    => d_dat_ch0_o,
       addr_ch0_i   => d_addr_ch0_i,
       dat_ch1_o    => d_dat_ch1_o,
       addr_ch1_i   => d_addr_ch1_i,
       dat_ch2_o    => d_dat_ch2_o,
       addr_ch2_i   => d_addr_ch2_i,
       dat_ch3_o    => d_dat_ch3_o,
       addr_ch3_i   => d_addr_ch3_i,
       dat_ch4_o    => d_dat_ch4_o,
       addr_ch4_i   => d_addr_ch4_i,
       dat_ch5_o    => d_dat_ch5_o,
       addr_ch5_i   => d_addr_ch5_i,
       dat_ch6_o    => d_dat_ch6_o,
       addr_ch6_i   => d_addr_ch6_i,
       dat_ch7_o    => d_dat_ch7_o,
       addr_ch7_i   => d_addr_ch7_i,
       dat_i        => dat_i,
       addr_i       => addr_i,
       tga_i        => tga_i,
       we_i         => we_i,
       stb_i        => stb_i,
       cyc_i        => cyc_i,
       qa_bank_o  => qa_d_bank,
       ack_bank_o => ack_d_bank);

  
  -----------------------------------------------------------------------------
  -- Instantiation of Z Banks Admin
  -----------------------------------------------------------------------------

  i_flux_quanta_banks_admin: flux_quanta_ram_admin
    port map (
        clk_50_i   => clk_50_i,
        rst_i      => rst_i,
        dat_ch0_o  => flux_quanta_dat_ch0_o,
        addr_ch0_i => flux_quanta_addr_ch0_i,
        dat_ch1_o  => flux_quanta_dat_ch1_o,
        addr_ch1_i => flux_quanta_addr_ch1_i,
        dat_ch2_o  => flux_quanta_dat_ch2_o,
        addr_ch2_i => flux_quanta_addr_ch2_i,
        dat_ch3_o  => flux_quanta_dat_ch3_o,
        addr_ch3_i => flux_quanta_addr_ch3_i,
        dat_ch4_o  => flux_quanta_dat_ch4_o,
        addr_ch4_i => flux_quanta_addr_ch4_i,
        dat_ch5_o  => flux_quanta_dat_ch5_o,
        addr_ch5_i => flux_quanta_addr_ch5_i,
        dat_ch6_o  => flux_quanta_dat_ch6_o,
        addr_ch6_i => flux_quanta_addr_ch6_i,
        dat_ch7_o  => flux_quanta_dat_ch7_o,
        addr_ch7_i => flux_quanta_addr_ch7_i,
        dat_i      => dat_i,
        addr_i     => addr_i,
        tga_i      => tga_i,
        we_i       => we_i,
        stb_i      => stb_i,
        cyc_i      => cyc_i,
        qa_bank_o  => qa_flux_quanta_bank,
        ack_bank_o => ack_flux_quanta_bank);


  -----------------------------------------------------------------------------
  -- Instantiation of ADC Offset Banks Admin
  -----------------------------------------------------------------------------

  i_adc_offset_banks_admin: adc_offset_banks_admin
    port map (
        clk_50_i              => clk_50_i,
        rst_i                 => rst_i,
        adc_offset_dat_ch0_o  => adc_offset_dat_ch0_o,
        adc_offset_addr_ch0_i => adc_offset_addr_ch0_i,
        adc_offset_dat_ch1_o  => adc_offset_dat_ch1_o,
        adc_offset_addr_ch1_i => adc_offset_addr_ch1_i,
        adc_offset_dat_ch2_o  => adc_offset_dat_ch2_o,
        adc_offset_addr_ch2_i => adc_offset_addr_ch2_i,
        adc_offset_dat_ch3_o  => adc_offset_dat_ch3_o,
        adc_offset_addr_ch3_i => adc_offset_addr_ch3_i,
        adc_offset_dat_ch4_o  => adc_offset_dat_ch4_o,
        adc_offset_addr_ch4_i => adc_offset_addr_ch4_i,
        adc_offset_dat_ch5_o  => adc_offset_dat_ch5_o,
        adc_offset_addr_ch5_i => adc_offset_addr_ch5_i,
        adc_offset_dat_ch6_o  => adc_offset_dat_ch6_o,
        adc_offset_addr_ch6_i => adc_offset_addr_ch6_i,
        adc_offset_dat_ch7_o  => adc_offset_dat_ch7_o,
        adc_offset_addr_ch7_i => adc_offset_addr_ch7_i,
        dat_i                 => dat_i,
        addr_i                => addr_i,
        tga_i                 => tga_i,
        we_i                  => we_i,
        stb_i                 => stb_i,
        cyc_i                 => cyc_i,
        qa_adc_offset_bank_o  => qa_adc_offset_bank,
        ack_adc_offset_bank_o => ack_adc_offset_bank);

  
  -----------------------------------------------------------------------------
  -- Instantiation of Miscellanous Bank Admin
  -----------------------------------------------------------------------------
  i_misc_banks_admin: misc_banks_admin
    port map (
        clk_50_i                => clk_50_i,
        rst_i                   => rst_i,
        sa_bias_ch0_o           => sa_bias_ch0_o,
        offset_dat_ch0_o        => offset_dat_ch0_o,
        const_val_ch0_o         => const_val_ch0_o,
        sa_bias_ch1_o           => sa_bias_ch1_o,
        offset_dat_ch1_o        => offset_dat_ch1_o,
        const_val_ch1_o         => const_val_ch1_o,
        sa_bias_ch2_o           => sa_bias_ch2_o,
        offset_dat_ch2_o        => offset_dat_ch2_o,
        const_val_ch2_o         => const_val_ch2_o,
        sa_bias_ch3_o           => sa_bias_ch3_o,
        offset_dat_ch3_o        => offset_dat_ch3_o,
        const_val_ch3_o         => const_val_ch3_o,
        sa_bias_ch4_o           => sa_bias_ch4_o,
        offset_dat_ch4_o        => offset_dat_ch4_o,
        const_val_ch4_o         => const_val_ch4_o,
        sa_bias_ch5_o           => sa_bias_ch5_o,
        offset_dat_ch5_o        => offset_dat_ch5_o,
        const_val_ch5_o         => const_val_ch5_o,
        sa_bias_ch6_o           => sa_bias_ch6_o,
        offset_dat_ch6_o        => offset_dat_ch6_o,
        const_val_ch6_o         => const_val_ch6_o,
        sa_bias_ch7_o           => sa_bias_ch7_o,
        offset_dat_ch7_o        => offset_dat_ch7_o,
        const_val_ch7_o         => const_val_ch7_o,
        filter_coeff0_o         => filter_coeff0_o,
        filter_coeff1_o         => filter_coeff1_o,
        filter_coeff2_o         => filter_coeff2_o,
        filter_coeff3_o         => filter_coeff3_o,
        filter_coeff4_o         => filter_coeff4_o,
        filter_coeff5_o         => filter_coeff5_o,
        filter_coeff6_o         => filter_coeff6_o,
        servo_mode_o            => servo_mode_o,
        ramp_step_size_o        => ramp_step_size_o,
        ramp_amp_o              => ramp_amp_o,
        num_ramp_frame_cycles_o => num_ramp_frame_cycles_o,
        flux_jumping_en_o       => flux_jumping_en_o,
        dat_i                   => dat_i,
        addr_i                  => addr_i,
        tga_i                   => tga_i,
        we_i                    => we_i,
        stb_i                   => stb_i,
        cyc_i                   => cyc_i,
        qa_misc_bank_o          => qa_misc_bank,
        ack_misc_bank_o         => ack_misc_bank);

  -----------------------------------------------------------------------------
  -- Output MUX to Dispatch:
  -- 
  -- 1. addr_i selects which Admin is sending its output to the dispatch.  The
  -- default connection is to data=0.
  --
  -- 2. Acknowlege is ORing of the acknowledge signals from all Admins.
  -----------------------------------------------------------------------------

  ack_o <= ack_p_bank or ack_d_bank or ack_i_bank or ack_flux_quanta_bank or
           ack_adc_offset_bank or ack_misc_bank;
  

  with addr_i select
    dat_o <=
    qa_p_bank           when GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
                             GAINP3_ADDR | GAINP4_ADDR | GAINP5_ADDR |
                             GAINP6_ADDR | GAINP7_ADDR,
    qa_i_bank           when GAINI0_ADDR | GAINI1_ADDR | GAINI2_ADDR |
                             GAINI3_ADDR | GAINI4_ADDR | GAINI5_ADDR |
                             GAINI6_ADDR | GAINI7_ADDR,
    qa_d_bank           when GAIND0_ADDR | GAIND1_ADDR | GAIND2_ADDR |
                             GAIND3_ADDR | GAIND4_ADDR | GAIND5_ADDR |
                             GAIND6_ADDR | GAIND7_ADDR,
    qa_flux_quanta_bank when FLX_QUANTA0_ADDR | FLX_QUANTA1_ADDR | FLX_QUANTA2_ADDR | FLX_QUANTA3_ADDR |
                             FLX_QUANTA4_ADDR | FLX_QUANTA5_ADDR | FLX_QUANTA6_ADDR | FLX_QUANTA7_ADDR,
    qa_adc_offset_bank  when ADC_OFFSET0_ADDR | ADC_OFFSET1_ADDR |
                             ADC_OFFSET2_ADDR | ADC_OFFSET3_ADDR |
                             ADC_OFFSET4_ADDR | ADC_OFFSET5_ADDR |
                             ADC_OFFSET6_ADDR | ADC_OFFSET7_ADDR,
    qa_misc_bank        when FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                             RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                             SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR,
    
    (others => '0')     when others;        -- default to zero



  
end struct;
